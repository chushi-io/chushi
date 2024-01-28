package models

import (
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
	Vcs            WorkspaceVcsConnection `gorm:"embedded;embeddedPrefix:vcs_"`
	Version        string                 `json:"version"`
	Locked         bool                   `json:"locked"`
	Lock           WorkspaceLock          `gorm:"embedded;embeddedPrefix:lock_" json:"lock,omitempty"`
	OrganizationID string                 `json:"organization_id"`
	Organization   Organization
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
	Delete(workspaceId string) error
	FindById(workspaceId string) (*Workspace, error)
	FindAll() ([]Workspace, error)
	FindAllForOrg(organizationId string) ([]Workspace, error)
}

type WorkspacesRepositoryImpl struct {
	Db *gorm.DB
}

func NewWorkspacesRepository(db *gorm.DB) WorkspacesRepository {
	return &WorkspacesRepositoryImpl{Db: db}
}

func (w WorkspacesRepositoryImpl) Save(workspace *Workspace) error {
	return nil
}

func (w WorkspacesRepositoryImpl) Update(workspace *Workspace) error {
	return nil
}

func (w WorkspacesRepositoryImpl) Delete(workspaceId string) error {
	return nil
}

func (w WorkspacesRepositoryImpl) FindById(workspaceId string) (*Workspace, error) {
	return &Workspace{}, nil
}

func (w WorkspacesRepositoryImpl) FindAll() ([]Workspace, error) {
	return []Workspace{}, nil
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
