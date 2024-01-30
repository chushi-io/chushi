package models

import (
	"errors"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"
	"gorm.io/gorm"
	"time"
)

type Workspace struct {
	Base
	Name           string                 `json:"name"`
	AllowDestroy   bool                   `json:"allow_destroy"`
	AutoApply      bool                   `json:"auto_apply"`
	AutoDestroyAt  *time.Time             `json:"auto_destroy_at" sql:"index"`
	ExecutionMode  string                 `json:"execution_mode"`
	Vcs            WorkspaceVcsConnection `gorm:"embedded;embeddedPrefix:vcs_" json:"vcs"`
	Version        string                 `json:"version"`
	Locked         bool                   `json:"locked"`
	Lock           WorkspaceLock          `gorm:"embedded;embeddedPrefix:lock_" json:"lock,omitempty"`
	OrganizationID uuid.UUID              `json:"organization_id"`
	Organization   Organization           `json:"-"`
}

type WorkspaceVcsConnection struct {
	Source           string   `json:"source"`
	Branch           string   `json:"branch"`
	Patterns         []string `json:"patterns" gorm:"serializer:json"`
	Prefixes         []string `json:"prefixes" gorm:"serializer:json"`
	WorkingDirectory string   `json:"working_directory"`
}

type WorkspaceLock struct {
	By string `json:"by"`
	At string `json:"at"`
	Id string `json:"id"`
}

type WorkspacesRepository interface {
	Save(workspace *Workspace) error
	Update(workspace *Workspace) error
	Lock(workspace *Workspace) error
	Unlock(workspace *Workspace) error
	Delete(workspaceId string) error
	FindById(organizationId uuid.UUID, workspaceId string) (*Workspace, error)
	FindAll() ([]Workspace, error)
	FindAllForOrg(organizationId uuid.UUID) ([]Workspace, error)
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

func (w WorkspacesRepositoryImpl) Update(workspace *Workspace) error {
	return nil
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
		Scopes(BelongsToOrganization(organizationId)).
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

type WorkspacesService interface {
	Create(workspace *Workspace) error
	Update(workspace *Workspace) error
	Delete(workspaceId string) error
	FindById(workspaceId string) (*Workspace, error)
	FindAll() ([]Workspace, error)
}

type WorkspacesServiceImpl struct {
	Repository WorkspacesRepository
	Validate   *validator.Validate
}

func NewWorkspacesServiceImpl(repository WorkspacesRepository, validate *validator.Validate) WorkspacesService {
	return &WorkspacesServiceImpl{
		Repository: repository,
		Validate:   validate,
	}
}

func (s WorkspacesServiceImpl) Create(workspace *Workspace) error {
	//err := s.Validate.Struct(workspace)
	return nil
}

func (s WorkspacesServiceImpl) FindAll() ([]Workspace, error) {
	result, _ := s.Repository.FindAll()

	//var workspaces []Workspace
	return result, nil
}

func (s WorkspacesServiceImpl) FindById(workspaceId string) (*Workspace, error) {
	return &Workspace{}, nil
}

func (s WorkspacesServiceImpl) Delete(workspaceId string) error {
	return nil
}

func (s WorkspacesServiceImpl) Update(workspace *Workspace) error {
	return nil
}
