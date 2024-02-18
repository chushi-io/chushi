package run

import (
	"github.com/chushi-io/chushi/internal/resource/agent"
	"github.com/chushi-io/chushi/internal/resource/workspaces"
	"github.com/chushi-io/chushi/pkg/types"
	"github.com/google/uuid"
	"time"
)

type Run struct {
	ID               uuid.UUID            `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`
	CreatedAt        time.Time            `json:"created_at"`
	UpdatedAt        time.Time            `json:"updated_at"`
	DeletedAt        *time.Time           `sql:"index" json:"deleted_at"`
	Status           types.RunStatus      `json:"status"`
	WorkspaceID      uuid.UUID            `json:"workspace_id"`
	Workspace        workspaces.Workspace `json:"-"`
	Add              int                  `json:"add"`
	Change           int                  `json:"change"`
	Destroy          int                  `json:"destroy"`
	ManagedResources int                  `json:"managed_resources"`
	CompletedAt      *time.Time           `json:"completed_at"`
	Operation        string               `json:"operation"`

	// Agent configuration
	AgentID *uuid.UUID  `json:"-" gorm:"default:null"`
	Agent   agent.Agent `json:"agent,omitempty"`
}
