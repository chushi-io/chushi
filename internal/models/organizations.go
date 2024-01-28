package models

import "gorm.io/gorm"

type Organization struct {
	Base
	Name string `json:"name" gorm:"index:idx_name,unique;not_null"`
}

type OrganizationRepository interface {
	Save(org *Organization) error
	Update(org Organization)
	Delete(organizationId string)
	FindById(organizationId string) (*Organization, error)
	All() ([]Organization, error)
}

type OrganizationRepositoryImpl struct {
	Db *gorm.DB
}

func NewOrganizationRepository(db *gorm.DB) OrganizationRepository {
	return &OrganizationRepositoryImpl{Db: db}
}

func (o OrganizationRepositoryImpl) Save(org *Organization) error {
	if result := o.Db.Create(org); result.Error != nil {
		return result.Error
	}
	return nil
}

func (o OrganizationRepositoryImpl) Update(org Organization) {

}

func (o OrganizationRepositoryImpl) Delete(organizationId string) {

}

func (o OrganizationRepositoryImpl) FindById(organizationId string) (*Organization, error) {
	var org Organization

	if result := o.Db.First(&org, "name = ?", organizationId); result.Error != nil {
		return nil, result.Error
	}
	return &org, nil
}

func (o OrganizationRepositoryImpl) All() ([]Organization, error) {
	var orgs []Organization
	if result := o.Db.Find(&orgs); result.Error != nil {
		return []Organization{}, result.Error
	}
	return orgs, nil
}
