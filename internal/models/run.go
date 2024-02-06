package models

import (
	"fmt"
	"github.com/google/uuid"
	"gorm.io/gorm"
	"time"
)

// TODO: Does run make sense as the unit of work? Each individual
// run does _either_ a plan or apply, there's currently no relation
// between a "RunGroup" that attributes 1 "plan" run for the workspace,
// and an associated "apply" that applies the generated plan. For the
// purposes of reporting / visualization, it probably makes sense to
// have a single Execution, which references the plan / apply runs?

// DECISION: Instead, we'll simply refactor "Runs" to be a higher level
// object. We'll add states to represent planning, applying, pending_approval,
// and execute a run up to 2 times. Once to plan, store the plan output,
// and request approval if necessary. Then again to apply the stored plan
type Run struct {
	Base
	Status           string     `json:"status"`
	WorkspaceID      string     `json:"workspace_id"`
	Workspace        Workspace  `json:"-"`
	Add              int        `json:"add"`
	Change           int        `json:"change"`
	Destroy          int        `json:"destroy"`
	ManagedResources int        `json:"managed_resources"`
	CompletedAt      *time.Time `json:"completed_at"`
	Operation        string     `json:"operation"`

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
