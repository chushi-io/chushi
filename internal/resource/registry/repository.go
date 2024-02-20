package registry

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Repository interface {
	List(params *ListModuleParams) ([]Module, error)
	ListModuleVersions(params *ListModuleVersionParams) ([]ModuleVersion, error)
	GetVersion(params *GetModuleVersionParams) (*ModuleVersion, error)
}

type RepositoryImpl struct {
	Database *gorm.DB
}

type ListModuleParams struct {
	Namespace string
	Provider  string
}

func (ri RepositoryImpl) List(params *ListModuleParams) ([]Module, error) {
	return []Module{}, nil
}

type ListModuleVersionParams struct {
	Namespace string
	Name      string
	Provider  string
	ModuleId  uuid.UUID
}

func (ri RepositoryImpl) ListModuleVersions(params *ListModuleVersionParams) ([]ModuleVersion, error) {
	return []ModuleVersion{}, nil
}

type GetModuleVersionParams struct {
	Namespace string
	Name      string
	Provider  string
	Version   string
}

func (ri RepositoryImpl) GetVersion(params *GetModuleVersionParams) (*ModuleVersion, error) {
	return nil, nil
}
