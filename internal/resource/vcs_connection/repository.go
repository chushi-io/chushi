package vcs_connection

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Repository interface {
	List(organizationId uuid.UUID) ([]VcsConnection, error)
	Get(organizationId uuid.UUID, connectionId uuid.UUID) (*VcsConnection, error)
	GetByWebhookId(webhookId uuid.UUID) (*VcsConnection, error)
	Create(connection *VcsConnection) (*VcsConnection, error)
	Delete(organizationId uuid.UUID, connectionId uuid.UUID) error
}

func New(db *gorm.DB) Repository {
	return &RepositoryImpl{Db: db}
}

type RepositoryImpl struct {
	Db *gorm.DB
}

func (vcr *RepositoryImpl) List(organizationId uuid.UUID) ([]VcsConnection, error) {
	var connections []VcsConnection
	result := vcr.Db.Where("organization_id = ?", organizationId).Find(&connections)
	if result.Error != nil {
		return []VcsConnection{}, result.Error
	}
	return connections, nil
}

func (vcr *RepositoryImpl) Get(organizationId uuid.UUID, connectionId uuid.UUID) (*VcsConnection, error) {
	var connection VcsConnection
	result := vcr.Db.Where("organization_id = ?", organizationId).Find(&connection, "id = ?", connectionId)
	return &connection, result.Error
}

func (vcr *RepositoryImpl) GetByWebhookId(webhookId uuid.UUID) (*VcsConnection, error) {
	var connection VcsConnection
	result := vcr.Db.Where("webhook_id = ?", webhookId).First(&connection)
	return &connection, result.Error
}

func (vcr *RepositoryImpl) Create(connection *VcsConnection) (*VcsConnection, error) {
	result := vcr.Db.Save(connection)
	return connection, result.Error
}

func (vcr *RepositoryImpl) Delete(organizationId uuid.UUID, connectionId uuid.UUID) error {
	return vcr.Db.Where("organization_id = ?", organizationId).Delete(&VcsConnection{
		ID: connectionId,
	}).Error
}
