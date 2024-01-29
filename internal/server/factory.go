package server

import (
	"github.com/robwittman/chushi/internal/models"
	"github.com/robwittman/chushi/internal/server/endpoints/organizations"
	"github.com/robwittman/chushi/internal/server/endpoints/terraform"
	"github.com/robwittman/chushi/internal/server/endpoints/vcs_connections"
	"github.com/robwittman/chushi/internal/server/endpoints/workspaces"
	"gorm.io/gorm"
)

type Factory struct {
	Database *gorm.DB
}

func (f *Factory) NewTerraformController() *terraform.Controller {
	return &terraform.Controller{}
}

func (f *Factory) NewWorkspaceController() *workspaces.Controller {
	return &workspaces.Controller{
		Repository: models.NewWorkspacesRepository(f.Database),
	}
}

func (f *Factory) NewVcsConnectionsController() *vcs_connections.Controller {
	return &vcs_connections.Controller{}
}

func (f *Factory) NewOrganizationsController() *organizations.Controller {
	return &organizations.Controller{
		Repository: models.NewOrganizationRepository(f.Database),
	}
}
