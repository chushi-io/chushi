package variables

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type SetRepository interface {
	List(params *ListVariableSetParams) ([]VariableSet, error)
	Get(variableSetId uuid.UUID) (*VariableSet, error)
	Create(variableSet *VariableSet) (*VariableSet, error)
	Update(variableSet *VariableSet) error
	Delete(variableSetId uuid.UUID) error

	AttachToOrganization(variableSetId uuid.UUID, organizationId uuid.UUID) error
	DetachFromOrganization(variableSetId uuid.UUID, organizationId uuid.UUID) error
	AttachToWorkspace(variableSetId uuid.UUID, workspaceId uuid.UUID) error
	DetachFromWorkspace(variableSetId uuid.UUID, workspaceId uuid.UUID) error
}

type ListVariableSetParams struct {
	OrganizationId *uuid.UUID
	WorkspaceId    *uuid.UUID
}

type SetRepositoryImpl struct {
	Db *gorm.DB
}

func NewVariableSetsRepository(db *gorm.DB) SetRepository {
	return &SetRepositoryImpl{Db: db}
}

func (sri SetRepositoryImpl) List(params *ListVariableSetParams) ([]VariableSet, error) {
	var variableSets []VariableSet
	result := sri.Db.Where("organization_id = ?", params.OrganizationId).Find(&variableSets)
	if result.Error != nil {
		return []VariableSet{}, result.Error
	}
	return variableSets, nil
}

func (sri SetRepositoryImpl) Get(variableSetId uuid.UUID) (*VariableSet, error) {
	var variableSet VariableSet
	result := sri.Db.Where("id = ?", variableSetId).Preload("Variables").Find(&variableSet)
	if result.Error != nil {
		return nil, result.Error
	}

	return &variableSet, nil
}

func (sri SetRepositoryImpl) Create(variableSet *VariableSet) (*VariableSet, error) {
	if result := sri.Db.Create(variableSet); result.Error != nil {
		return nil, result.Error
	}
	return variableSet, nil
}

func (sri SetRepositoryImpl) Update(set *VariableSet) error {
	//return sri.Db.
	//	Model(&VariableSet{}).
	//	Where("id = ?", set.).
	//	Updates(map[string]interface{}{
	//		"description": params.
	//}).Error
	return nil
}

func (sri SetRepositoryImpl) Delete(variableSetId uuid.UUID) error {
	return sri.Db.
		Where("id = ?", variableSetId).
		Delete(&VariableSet{}).
		Error
}

func (sri SetRepositoryImpl) AttachToOrganization(variableSetId uuid.UUID, organizationId uuid.UUID) error {
	return sri.Db.Create(&OrganizationVariableSet{
		OrganizationID: organizationId,
		VariableSetID:  variableSetId,
	}).Error
}

func (sri SetRepositoryImpl) DetachFromOrganization(variableSetId uuid.UUID, organizationId uuid.UUID) error {
	return sri.Db.
		Where("variable_set_id = ?", variableSetId).
		Where("organization_id = ?", organizationId).
		Delete(&OrganizationVariableSet{}).Error
}

func (sri SetRepositoryImpl) AttachToWorkspace(variableSetId uuid.UUID, workspaceId uuid.UUID) error {
	return sri.Db.Create(&WorkspaceVariableSet{
		WorkspaceID:   workspaceId,
		VariableSetID: variableSetId,
	}).Error
}

func (sri SetRepositoryImpl) DetachFromWorkspace(variableSetId uuid.UUID, workspaceId uuid.UUID) error {
	return sri.Db.
		Where("variable_set_id = ?", variableSetId).
		Where("workspace_id = ?", workspaceId).
		Delete(&WorkspaceVariableSet{}).Error
}
