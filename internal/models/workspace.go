package models

import (
	"github.com/go-playground/validator/v10"
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
	Save(workspace Workspace)
	Update(workspace Workspace)
	Delete(workspaceId string)
	FindById(workspaceId string) (Workspace, error)
	FindAll() []Workspace
}

type WorkspacesRepositoryImpl struct {
	Db *gorm.DB
}

func NewWorkspacesRepository(db *gorm.DB) WorkspacesRepository {
	return &WorkspacesRepositoryImpl{Db: db}
}

func (w WorkspacesRepositoryImpl) Save(workspace Workspace) {

}

func (w WorkspacesRepositoryImpl) Update(workspace Workspace) {

}

func (w WorkspacesRepositoryImpl) Delete(workspaceId string) {

}

func (w WorkspacesRepositoryImpl) FindById(workspaceId string) (Workspace, error) {
	return Workspace{}, nil
}

func (w WorkspacesRepositoryImpl) FindAll() []Workspace {
	return []Workspace{}
}

type WorkspacesService interface {
	Create(workspace Workspace)
	Update(workspace Workspace)
	Delete(workspaceId string)
	FindById(workspaceId string) Workspace
	FindAll() []Workspace
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

func (s WorkspacesServiceImpl) Create(workspace Workspace) {
	//err := s.Validate.Struct(workspace)
}

func (s WorkspacesServiceImpl) FindAll() []Workspace {
	result := s.Repository.FindAll()

	//var workspaces []Workspace
	return result
}

func (s WorkspacesServiceImpl) FindById(workspaceId string) Workspace {
	return Workspace{}
}

func (s WorkspacesServiceImpl) Delete(workspaceId string) {

}

func (s WorkspacesServiceImpl) Update(workspace Workspace) {
	return
}
