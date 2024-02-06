package run

import (
	"fmt"
	"github.com/google/uuid"
	"github.com/robwittman/chushi/pkg/types"
	"gorm.io/gorm"
)

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
	Status      types.RunStatus
	WorkspaceId string
}

type UpdateRunParams struct {
	Add    int    `json:"add,omitempty"`
	Change int    `json:"change,omitempty"`
	Remove int    `json:"remove,omitempty"`
	Status string `json:"status,omitempty"`
}

func NewRunRepository(db *gorm.DB) RunRepository {
	return &RunRepositoryImpl{Db: db}
}

func (r *RunRepositoryImpl) List(params *RunListParams) ([]Run, error) {
	var runs []Run
	query := r.Db
	if params.AgentId != "" {
		query = query.Where("agent_id = ?", params.AgentId)
	}
	fmt.Println(params.Status)
	if params.Status != "" {
		fmt.Println("filtering on status")
		query = query.Where("status = ?", params.Status)
	}
	if params.WorkspaceId != "" {
		query = query.Where("workspace_id = ?", params.WorkspaceId)
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
	// TODO: Whenever we create a run, we should mark any currently
	// "pending" runs as "superseded"?
	result := r.Db.Create(run)
	return run, result.Error
}

func (r *RunRepositoryImpl) Update(run *Run) (*Run, error) {
	result := r.Db.Save(run)
	return run, result.Error
}

func (r *RunRepositoryImpl) Delete(runId uuid.UUID) error {
	result := r.Db.Where("id = ?", runId.String()).Delete(&Run{})
	return result.Error
}
