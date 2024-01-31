package models

type Run struct {
	Base
	Status           string `json:"status"`
	WorkspaceID      string `json:"workspace_id"`
	Workspace        Workspace
	Add              int `json:"add"`
	Change           int `json:"change"`
	Destroy          int `json:"destroy"`
	ManagedResources int `json:"managed_resources"`
}
