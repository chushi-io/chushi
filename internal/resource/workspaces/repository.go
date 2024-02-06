package workspaces

import (
	"errors"
	"github.com/google/uuid"
	"github.com/robwittman/chushi/internal/scopes"
	"gorm.io/gorm"
)

type WorkspacesRepository interface {
	Save(workspace *Workspace) error
	Update(workspace *Workspace) (*Workspace, error)
	Lock(workspace *Workspace) error
	Unlock(workspace *Workspace) error
	Delete(workspaceId string) error
	FindById(organizationId uuid.UUID, workspaceId string) (*Workspace, error)
	FindAll() ([]Workspace, error)
	FindAllForOrg(organizationId uuid.UUID) ([]Workspace, error)
}

type UpdateWorkspaceParams struct {
	AgentId *uuid.UUID `json:"agent_id,omitempty"`
}

type WorkspacesRepositoryImpl struct {
	Db *gorm.DB
}

func NewWorkspacesRepository(db *gorm.DB) WorkspacesRepository {
	return &WorkspacesRepositoryImpl{Db: db}
}

func (w WorkspacesRepositoryImpl) Save(workspace *Workspace) error {
	if result := w.Db.Create(workspace); result.Error != nil {
		return result.Error
	}
	return nil
}

func (w WorkspacesRepositoryImpl) Update(workspace *Workspace) (*Workspace, error) {
	result := w.Db.Save(workspace)
	return workspace, result.Error
}

func (w WorkspacesRepositoryImpl) Delete(workspaceId string) error {
	return nil
}

func (w WorkspacesRepositoryImpl) FindById(organizationId uuid.UUID, workspaceId string) (*Workspace, error) {
	var workspace Workspace
	// If someone decides they want to name their workspace using a UUID,
	// this will start to fail. The UUID check will pass, but the
	// resource is requested by name...
	search := []string{"id = ?", workspaceId}
	if _, err := uuid.Parse(workspaceId); err != nil {
		search = []string{"name = ?", workspaceId}
	}
	if result := w.Db.
		Scopes(scopes.BelongsToOrganization(organizationId)).
		Where(search[0], search[1]).
		First(&workspace); result.Error != nil {
		return nil, result.Error
	}
	return &workspace, nil
}

func (w WorkspacesRepositoryImpl) FindAll() ([]Workspace, error) {
	return []Workspace{}, nil
}

func (w WorkspacesRepositoryImpl) Lock(workspace *Workspace) error {
	result := w.Db.
		Model(&Workspace{}).
		Where("id = ?", workspace.ID.String()).
		Where("locked = ?", false).
		Update("locked", true)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected < 0 {
		return errors.New("workspace already locked")
	}
	return nil
}

func (w WorkspacesRepositoryImpl) Unlock(workspace *Workspace) error {
	result := w.Db.
		Model(&Workspace{}).
		Where("id = ?", workspace.ID.String()).
		Where("locked = ?", true).
		Update("locked", false)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected < 0 {
		return errors.New("workspace already unlocked")
	}
	return nil
}

func (w WorkspacesRepositoryImpl) FindAllForOrg(organizationId uuid.UUID) ([]Workspace, error) {
	var workspaces []Workspace
	if result := w.Db.Where("organization_id = ?", organizationId).Find(&workspaces); result.Error != nil {
		return []Workspace{}, result.Error
	}
	return workspaces, nil
}
