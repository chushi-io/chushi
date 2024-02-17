package variables

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Repository interface {
	// Manage Variables
	List(params *ListVariableParams) ([]Variable, error)
	Get(variableId uuid.UUID) (*Variable, error)
	Create(variable *Variable) (*Variable, error)
	Update(variable *Variable) (*Variable, error)
	Delete(variableId uuid.UUID) error

	AttachToWorkspace(variableId uuid.UUID, workspaceId uuid.UUID) error
	DetachFromWorkspace(variableId uuid.UUID, workspaceId uuid.UUID) error
}

type ListVariableParams struct{}

type RepositoryImpl struct {
	Db *gorm.DB
}

func (v RepositoryImpl) List(params *ListVariableParams) ([]Variable, error) {
	return []Variable{}, nil
}

func (v RepositoryImpl) Get(variableId uuid.UUID) (*Variable, error) {
	return nil, nil
}

func (v RepositoryImpl) Create(variable *Variable) (*Variable, error) {
	return nil, nil
}

func (v RepositoryImpl) Update(variable *Variable) (*Variable, error) {
	return nil, nil
}

func (v RepositoryImpl) Delete(variableId uuid.UUID) error {
	return nil
}

func (v RepositoryImpl) AttachToWorkspace(variableId uuid.UUID, workspaceId uuid.UUID) error {
	return nil
}

func (v RepositoryImpl) DetachFromWorkspace(variableId uuid.UUID, workspaceId uuid.UUID) error {
	return nil
}

//
//func (w WorkspacesRepositoryImpl) ListVariables(workspaceId uuid.UUID) ([]Variable, error) {
//	var variables []Variable
//	result := w.Db.Where("workspace_id = ?", workspaceId).Find(&variables)
//	if result.Error != nil {
//		return []Variable{}, result.Error
//	}
//	return variables, nil
//}
//
//func (w WorkspacesRepositoryImpl) GetVariable(variableId uuid.UUID) (*Variable, error) {
//	var variable Variable
//	result := w.Db.First(&variable, "id = ?", variableId)
//	if result.Error != nil {
//		return nil, result.Error
//	}
//	return &variable, nil
//}
//
//func (w WorkspacesRepositoryImpl) SaveVariable(variable *Variable) error {
//	return w.Db.Save(variable).Error
//}
//
//func (w WorkspacesRepositoryImpl) DeleteVariable(variableId uuid.UUID) error {
//	return w.Db.Delete(&Variable{}, "id = ?", variableId).Error
//}
