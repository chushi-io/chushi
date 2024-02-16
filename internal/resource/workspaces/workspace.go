package workspaces

import (
	"github.com/chushi-io/chushi/internal/resource/agent"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/google/uuid"
	"time"
)

type Workspace struct {
	ID        uuid.UUID  `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `sql:"index" json:"deleted_at"`

	// Name of the workspace
	Name string `gorm:"uniqueIndex:idx_name,unique" json:"name"`
	// Does the workspace allow destroy plans
	AllowDestroy bool `json:"allow_destroy"`
	// Does the workspace auto apply planned runs
	AutoApply bool `json:"auto_apply"`
	// Schedule the workspace for auto destruction
	AutoDestroyAt *time.Time `json:"auto_destroy_at" sql:"index"`
	// How our applies executed? Possible values are
	// - apply_on_pull_request
	// - apply_on_merge
	ExecutionMode string `json:"execution_mode"`
	// Configuration for the VCS containing the IaC
	Vcs WorkspaceVcsConnection `gorm:"embedded;embeddedPrefix:vcs_" json:"vcs"`
	// The opentofu version for the workspace
	// Can be set to 'latest' to always pull the latest available version
	Version string `json:"version"`
	// Is the workspace currently locked
	Locked bool `json:"locked"`
	// Lock configuration
	// TODO: Just move this to top level fields, no need
	// to embed this as a separate object
	Lock WorkspaceLock `gorm:"embedded;embeddedPrefix:lock_" json:"lock,omitempty"`
	// ID of the owning organization
	OrganizationID uuid.UUID                 `gorm:"uniqueIndex:idx_name,unique" json:"organization_id"`
	Organization   organization.Organization `json:"-"`

	// Agent configuration
	AgentID *uuid.UUID  `json:"-"`
	Agent   agent.Agent `json:"agent,omitempty"`

	// DriftDetection
	DriftDetection DriftDetection `gorm:"embedded;embeddedPrefix:drift_detection_" json:"drift_detection"`
}

type DriftDetection struct {
	Enabled  bool   `json:"enabled"`
	Schedule string `json:"schedule"`
}

type WorkspaceVcsConnection struct {
	// The Git URL for the workspace
	Source string `json:"source"`
	// Which branch we're applying / watching for PRs to
	Branch string `json:"branch"`
	// Patterns to match for executing
	Patterns []string `json:"patterns" gorm:"serializer:json"`
	// Prefixes to match for executing
	Prefixes []string `json:"prefixes" gorm:"serializer:json"`
	// Specify the working directory
	WorkingDirectory string    `json:"working_directory"`
	ConnectionId     uuid.UUID `json:"connection_id"`
}

type WorkspaceLock struct {
	// Who is the workspace locked by. Should be either
	// - user ID
	// - execution ID
	By string `json:"by"`
	// Time the workspace was locked at
	At string `json:"at"`
	// Lock ID
	Id string `json:"id"`
}

type Variable struct {
	ID        uuid.UUID  `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `sql:"index" json:"deleted_at"`

	Type        string     `json:"type"`
	Name        string     `json:"name"`
	Value       string     `json:"value"`
	WorkspaceID uuid.UUID  `json:"workspace_id"`
	Workspace   *Workspace `json:"-"`
}
