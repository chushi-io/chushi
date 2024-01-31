package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Agent struct {
	Base
	OrganizationID uuid.UUID    `json:"organization_id"`
	Organization   Organization `json:"-"`
	Status         string       `json:"status"`
}

type AgentRepository interface {
	List(organizationId uuid.UUID) ([]Agent, error)
	FindById(organizationId uuid.UUID, agentId string) (*Agent, error)
	Create(agent *Agent) (*Agent, error)
	Update(agent *Agent) (*Agent, error)
	Delete(agentId string) error
}

type AgentRepositoryImpl struct {
	Db *gorm.DB
}

func NewAgentRepository(db *gorm.DB) AgentRepository {
	return &AgentRepositoryImpl{Db: db}
}

func (a AgentRepositoryImpl) List(organizationId uuid.UUID) ([]Agent, error) {
	return []Agent{}, nil
}

func (a AgentRepositoryImpl) FindById(organizationId uuid.UUID, agentId string) (*Agent, error) {
	return nil, nil
}

func (a AgentRepositoryImpl) Create(agent *Agent) (*Agent, error) {
	return nil, nil
}

func (a AgentRepositoryImpl) Update(agent *Agent) (*Agent, error) {
	return nil, nil
}

func (a AgentRepositoryImpl) Delete(agentId string) error {
	return nil
}
