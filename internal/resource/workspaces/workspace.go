package workspaces

import (
	"github.com/chushi-io/chushi/internal/resource/agent"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/gin-gonic/gin"
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

func (w *Workspace) ToCloud() any {
	return gin.H{
		"data": gin.H{
			"attributes": gin.H{
				"actions": gin.H{
					"is-destroyable": w.AllowDestroy,
				},
				"allow-destroy-plan": w.AllowDestroy,
				//"apply-duration-average": 158000,
				"auto-apply": w.AutoApply,
				//"auto-apply-run-trigger": false,
				//"auto-destroy-at": null,
				//"auto-destroy-activity-duration": null,
				//"created-at":  w.CreatedAt.String(),
				"description": "",
				//"environment": "default",
				"execution-mode":        "remote",
				"file-triggers-enabled": true,
				"global-remote-state":   false,
				"latest-change-at":      "2021-06-23T17:50:48.815Z",
				"locked":                w.Locked,
				"name":                  w.Name,
				//"operations": true,
				"permissions": gin.H{
					"can-create-state-versions": true,
					"can-destroy":               true,
					"can-force-unlock":          true,
					"can-lock":                  true,
					"can-manage-run-tasks":      true,
					"can-manage-tags":           true,
					"can-queue-apply":           true,
					"can-queue-destroy":         true,
					"can-queue-run":             true,
					"can-read-settings":         true,
					"can-read-state-versions":   true,
					"can-read-variable":         true,
					"can-unlock":                true,
					"can-update":                true,
					"can-update-variable":       true,
					"can-force-delete":          true,
				},
				//"plan-duration-average": 20000,
				//"policy-check-failures": null,
				//"queue-all-runs": false,
				//"resource-count": 0,
				//"run-failures": 6,
				//"source": "terraform",
				//"source-name": null,
				//"source-url": null,
				//"speculative-enabled": true,
				//"structured-run-output-enabled": false,
				"terraform-version": w.Version,
				//"trigger-prefixes": [],
				//"updated-at": "2021-08-16T18:54:06.874Z",
				//"vcs-repo": null,
				//"vcs-repo-identifier": null,
				//"working-directory": null,
				//"workspace-kpis-runs-count": 7,
				//"setting-overwrites": {
				//"execution-mode": true,
				//"agent-pool": true
				//}
			},
			"id":            w.ID,
			"links":         gin.H{},
			"relationships": gin.H{},
			"type":          "workspaces",
		},
	}
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
