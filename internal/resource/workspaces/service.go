package workspaces

import "github.com/go-playground/validator/v10"

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
