package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Run struct {
	Base
	Status           string    `json:"status"`
	WorkspaceID      string    `json:"workspace_id"`
	Workspace        Workspace `json:"-"`
	Add              int       `json:"add"`
	Change           int       `json:"change"`
	Destroy          int       `json:"destroy"`
	ManagedResources int       `json:"managed_resources"`

	// Agent configuration
	AgentID *uuid.UUID `json:"-" gorm:"default:null"`
	Agent   *Agent     `json:"agent,omitempty"`
}

type RunRepository interface {
	List(params *RunListParams) ([]Run, error)
	Get(runId uuid.UUID) (*Run, error)
	Create(run *Run) (*Run, error)
	Update(run *Run) (*Run, error)
	Delete(runId uuid.UUID) error
}

type RunRepositoryImpl struct {
	Db *gorm.DB
}

type RunListParams struct {
	AgentId     string
	Status      string
	WorkspaceId string
}

type UpdateRunParams struct {
	Add    int `json:"add,omitempty"`
	Change int `json:"change,omitempty"`
	Remove int `json:"remove,omitempty"`
}

func NewRunRepository(db *gorm.DB) RunRepository {
	return &RunRepositoryImpl{Db: db}
}

func (r *RunRepositoryImpl) List(params *RunListParams) ([]Run, error) {
	var runs []Run
	query := r.Db
	if params.AgentId != "" {
		query.Where("agent_id = ?", params.AgentId)
	}
	if params.Status != "" {
		query.Where("status = ?", params.Status)
	}
	if params.WorkspaceId != "" {
		query.Where("workspace_id = ?", params.WorkspaceId)
	}
	result := query.Find(&runs)
	return runs, result.Error
}

func (r *RunRepositoryImpl) Get(runId uuid.UUID) (*Run, error) {
	var run Run
	result := r.Db.Where("id = ?", runId).First(&run)
	return &run, result.Error
}

func (r *RunRepositoryImpl) Create(run *Run) (*Run, error) {
	result := r.Db.Create(run)
	return run, result.Error
}

func (r *RunRepositoryImpl) Update(run *Run) (*Run, error) {
	return &Run{}, nil
}

func (r *RunRepositoryImpl) Delete(runId uuid.UUID) error {
	result := r.Db.Where("id = ?", runId.String()).Delete(&Run{})
	return result.Error
}
