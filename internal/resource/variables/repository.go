package variables

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Repository interface {
	// Manage Variables
	List(params *ListVariableParams) ([]Variable, error)
	ListForWorkspace(workspaceId uuid.UUID) ([]Variable, error)
	Get(variableId uuid.UUID) (*Variable, error)
	Create(variable *Variable) (*Variable, error)
	Update(variable *Variable) (*Variable, error)
	Delete(variableId uuid.UUID) error

	AttachToWorkspace(variableId uuid.UUID, workspaceId uuid.UUID) error
	DetachFromWorkspace(variableId uuid.UUID, workspaceId uuid.UUID) error
}

type ListVariableParams struct {
	WorkspaceId   *uuid.UUID
	VariableSetId *uuid.UUID
}

type RepositoryImpl struct {
	Db *gorm.DB
}

func NewVariableRepository(db *gorm.DB) Repository {
	return &RepositoryImpl{Db: db}
}

func (v RepositoryImpl) List(params *ListVariableParams) ([]Variable, error) {
	var variables []Variable
	query := v.Db.Where("organization_id = ?")
	if params.WorkspaceId != nil {
		query = query.Where("workspace_id = ?", params.WorkspaceId)
	}
	if params.VariableSetId != nil {
		query = query.Where("variable_set_id = ?", params.VariableSetId)
	}

	result := query.Find(&variables)
	if result.Error != nil {
		return []Variable{}, result.Error
	}

	return variables, nil
}

func (v RepositoryImpl) ListForWorkspace(workspace uuid.UUID) ([]Variable, error) {
	var directVariables []WorkspaceVariable
	result := v.Db.Where("workspace_id = ?", workspace).Find(&directVariables)
	if result.Error != nil {
		return []Variable{}, result.Error
	}

	var workspaceVariableSets []WorkspaceVariableSet
	result = v.Db.Where("workspace_id = ?", workspace).Find(&workspaceVariableSets)
	if result.Error != nil {
		return []Variable{}, result.Error
	}

	var variables []Variable
	for _, set := range workspaceVariableSets {
		var workspaceVars []Variable
		result = v.Db.Where("variable_set_id = ?", set.VariableSetID).Find(&workspaceVars)
		if result.Error != nil {
			return []Variable{}, result.Error
		}
		for _, wv := range workspaceVars {
			variables = append(variables, wv)
		}
	}

	for _, directVar := range directVariables {
		var workspaceVars []Variable
		result = v.Db.Where("variable_id = ?", directVar.VariableID).Find(&workspaceVars)
		if result.Error != nil {
			return []Variable{}, result.Error
		}
		for _, wv := range workspaceVars {
			variables = append(variables, wv)
		}
	}
	return variables, nil
}

func (v RepositoryImpl) Get(variableId uuid.UUID) (*Variable, error) {
	var variable Variable
	result := v.Db.Find(&variable, "id = ?", variableId)
	if result.Error != nil {
		return nil, result.Error
	}
	return &variable, nil
}

func (v RepositoryImpl) Create(variable *Variable) (*Variable, error) {
	result := v.Db.Create(variable)
	return variable, result.Error
}

func (v RepositoryImpl) Update(variable *Variable) (*Variable, error) {
	result := v.Db.Where("id = ?", variable.ID).Updates(map[string]interface{}{
		"value":       variable.Value,
		"description": variable.Description,
	})
	return variable, result.Error
}

func (v RepositoryImpl) Delete(variableId uuid.UUID) error {
	return v.Db.Delete(&Variable{}, "id = ?", variableId).Error
}

func (v RepositoryImpl) AttachToWorkspace(variableId uuid.UUID, workspaceId uuid.UUID) error {
	return v.Db.Create(&WorkspaceVariable{
		VariableID:  variableId,
		WorkspaceID: workspaceId,
	}).Error
}

func (v RepositoryImpl) DetachFromWorkspace(variableId uuid.UUID, workspaceId uuid.UUID) error {
	return v.Db.
		Where("workspace_id = ?").
		Where("variable_id = ?").
		Delete(&WorkspaceVariable{}).Error
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
