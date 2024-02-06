package run_manager

import (
	"github.com/google/uuid"
	"github.com/robwittman/chushi/internal/resource/run"
	"github.com/robwittman/chushi/internal/resource/workspaces"
	"github.com/robwittman/chushi/pkg/types"
)

type RunManager interface {
	CreateRun(params *CreateRunParams) (*CreateRunResponse, error)
}

type RunManagerImpl struct {
	RunsRepository       run.RunRepository
	WorkspacesRepository workspaces.WorkspacesRepository
}

func New(runRepo run.RunRepository, workspaceRepo workspaces.WorkspacesRepository) RunManager {
	return &RunManagerImpl{
		RunsRepository:       runRepo,
		WorkspacesRepository: workspaceRepo,
	}
}

type CreateRunParams struct {
	OrganizationId uuid.UUID
	WorkspaceId    uuid.UUID
	Operation      string
}

type CreateRunResponse struct {
	Run *run.Run
}

func (impl *RunManagerImpl) CreateRun(params *CreateRunParams) (*CreateRunResponse, error) {
	workspace, err := impl.WorkspacesRepository.FindById(params.OrganizationId, params.WorkspaceId.String())
	if err != nil {
		return nil, err
	}

	obj := &run.Run{
		Workspace: *workspace,
		AgentID:   workspace.AgentID,
		Status:    types.RunStatusPending,
		Operation: params.Operation,
	}

	if _, err := impl.RunsRepository.Create(obj); err != nil {
		return nil, err
	}

	// TODO: Start publishing these to stream endpoints
	// TODO: Supersede any neccessary runs
	return &CreateRunResponse{
		Run: obj,
	}, nil
}
