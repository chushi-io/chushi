package grpc

import (
	"connectrpc.com/connect"
	"context"
	"errors"
	"fmt"
	apiv1 "github.com/chushi-io/chushi/gen/api/v1"
	"github.com/chushi-io/chushi/internal/resource/agent"
	"github.com/chushi-io/chushi/internal/resource/vcs_connection"
	"github.com/chushi-io/chushi/internal/resource/workspaces"
	"github.com/google/uuid"
)

type WorkspaceServer struct {
	Repository    workspaces.WorkspacesRepository
	VcsRepository vcs_connection.Repository
}

func (ws *WorkspaceServer) GetWorkspace(
	ctx context.Context,
	request *connect.Request[apiv1.GetWorkspaceRequest],
) (
	*connect.Response[apiv1.GetWorkspaceResponse],
	error,
) {
	ag := ctx.Value("agent").(*agent.Agent)
	workspace, err := ws.Repository.FindById(
		ctx.Value("organization_id").(uuid.UUID),
		request.Msg.Id,
	)
	if err != nil {
		return nil, err
	}

	if *workspace.AgentID != ag.ID {
		fmt.Println(workspace.Agent.ID)
		fmt.Println(ag.ID)
		return nil, errors.New("not found")
	}
	return connect.NewResponse(&apiv1.GetWorkspaceResponse{
		Workspace: &apiv1.Workspace{
			Id:     workspace.ID.String(),
			Name:   workspace.Name,
			Locked: workspace.Locked,
			Vcs: &apiv1.WorkspaceVcs{
				Source:           workspace.Vcs.Source,
				Branch:           workspace.Vcs.Branch,
				Patterns:         workspace.Vcs.Patterns,
				Prefixes:         workspace.Vcs.Prefixes,
				WorkingDirectory: workspace.Vcs.WorkingDirectory,
				ConnectionId:     workspace.Vcs.ConnectionId.String(),
			},
		},
	}), nil
}

func (ws *WorkspaceServer) GetVcsConnection(
	ctx context.Context,
	request *connect.Request[apiv1.GetVcsConnectionRequest],
) (
	*connect.Response[apiv1.GetVcsConnectionResponse],
	error,
) {
	ag := ctx.Value("agent").(*agent.Agent)
	workspace, err := ws.Repository.FindById(
		ctx.Value("organization_id").(uuid.UUID),
		request.Msg.WorkspaceId,
	)
	if err != nil {
		return nil, err
	}

	if *workspace.AgentID != ag.ID {
		fmt.Println(workspace.Agent.ID)
		fmt.Println(ag.ID)
		return nil, errors.New("not found")
	}

	cid, err := uuid.Parse(request.Msg.ConnectionId)
	if err != nil {
		return nil, err
	}

	connection, err := ws.VcsRepository.Get(
		ctx.Value("organization_id").(uuid.UUID),
		cid,
	)
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&apiv1.GetVcsConnectionResponse{
		Token: connection.Github.PersonalAccessToken,
	}), nil
}

func (ws *WorkspaceServer) GetVariables(
	ctx context.Context,
	request *connect.Request[apiv1.GetVariablesRequest],
) (
	*connect.Response[apiv1.GetVariablesResponse],
	error,
) {
	ag := ctx.Value("agent").(*agent.Agent)
	workspace, err := ws.Repository.FindById(
		ctx.Value("organization_id").(uuid.UUID),
		request.Msg.WorkspaceId,
	)
	if err != nil {
		return nil, err
	}

	if *workspace.AgentID != ag.ID {
		fmt.Println(workspace.Agent.ID)
		fmt.Println(ag.ID)
		return nil, errors.New("not found")
	}

	// TODO: Get all the variables for the workspace
	variables := []*apiv1.Variable{}
	return connect.NewResponse(&apiv1.GetVariablesResponse{
		Variables: variables,
	}), nil
}
