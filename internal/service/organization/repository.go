package organization

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type OrganizationRepository interface {
	Save(org *Organization) error
	Update(org Organization)
	Delete(organizationId string)
	FindById(organizationId string) (*Organization, error)
	UserHasOrganization(userId string, organizationId string) (bool, error)
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

func (o OrganizationRepositoryImpl) FindById(organizationIdOrName string) (*Organization, error) {
	var org Organization

	_, err := uuid.Parse(organizationIdOrName)
	if err != nil {
		result := o.Db.
			Where("name = ?", organizationIdOrName).
			First(&org)
		return &org, result.Error
	}
	result := o.Db.
		Where("id = ?", organizationIdOrName).
		First(&org)
	return &org, result.Error
}

func (o OrganizationRepositoryImpl) All() ([]Organization, error) {
	var orgs []Organization
	if result := o.Db.Find(&orgs); result.Error != nil {
		return []Organization{}, result.Error
	}
	return orgs, nil
}

func (o OrganizationRepositoryImpl) UserHasOrganization(userId string, organizationId string) (bool, error) {
	var ou OrganizationUser
	check := o.Db.Where("organization_id = ?", organizationId).
		Where("user_id = ?", userId).First(&ou)
	if check.Error != nil {
		return false, check.Error
	}
	return true, nil
}
