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
	// Name of the workspace
	Name string `gorm:"index:idx_name,unique" json:"name"`
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
	OrganizationID uuid.UUID    `gorm:"index:idx_name,unique" json:"organization_id"`
	Organization   Organization `json:"-"`

	// Agent configuration
	AgentID *uuid.UUID `json:"-"`
	Agent   *Agent     `json:"agent,omitempty"`

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
	WorkingDirectory string `json:"working_directory"`
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
