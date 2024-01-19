package models

import "time"

type Workspace struct {
	Base
	Name          string                 `json:"name"`
	AllowDestroy  bool                   `json:"allow_destroy"`
	AutoApply     bool                   `json:"auto_apply"`
	AutoDestroyAt *time.Time             `json:"auto_destroy_at" sql:"index"`
	ExecutionMode string                 `json:"execution_mode"`
	Vcs           WorkspaceVcsConnection `gorm:"embedded;embeddedPrefix:vcs_"`
	Version       string                 `json:"version"`
}

type WorkspaceVcsConnection struct {
	Source           string   `json:"source"`
	Branch           string   `json:"branch"`
	Patterns         []string `json:"patterns" gorm:"serializer:json"`
	Prefixes         []string `json:"prefixes" gorm:"serializer:json"`
	WorkingDirectory string   `json:"working_directory"`
}
