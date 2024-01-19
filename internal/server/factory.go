package server

import (
	"github.com/robwittman/chushi/internal/server/endpoints/terraform"
	"github.com/robwittman/chushi/internal/server/endpoints/workspaces"
)

type Factory struct {
}

func (f *Factory) NewTerraformController() *terraform.Controller {
	return &terraform.Controller{}
}

func (f *Factory) NewWorkspaceController() *workspaces.Controller {
	return &workspaces.Controller{}
}
