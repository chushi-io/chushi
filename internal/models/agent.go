package models

import (
	"github.com/go-oauth2/oauth2/v4/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Agent struct {
	Base
	Name           string       `gorm:"index:idx_name,unique" json:"name"`
	OrganizationID uuid.UUID    `gorm:"index:idx_name,unique" json:"organization_id"`
	Organization   Organization `json:"-"`
	Status         string       `json:"status"`
	OauthClientID  string       `json:"oauth_client_id"`
	OauthClient    OauthClient  `json:"-"`
}

type AgentRepository interface {
	List(organizationId uuid.UUID) ([]Agent, error)
	FindById(organizationId uuid.UUID, agentId string) (*Agent, error)
	FindByClientId(clientId string) (*Agent, error)
	Create(agent *Agent) (*Agent, error)
	Update(agent *Agent) (*Agent, error)
	Delete(agentId string) error
}

type AgentRepositoryImpl struct {
	Db          *gorm.DB
	ClientStore *ClientStore
}

func NewAgentRepository(db *gorm.DB, clientStore *ClientStore) AgentRepository {
	return &AgentRepositoryImpl{
		Db:          db,
		ClientStore: clientStore,
	}
}

func (a AgentRepositoryImpl) List(organizationId uuid.UUID) ([]Agent, error) {
	var agents []Agent
	if result := a.Db.Where("organization_id = ?", organizationId).Find(&agents); result.Error != nil {
		return []Agent{}, result.Error
	}
	return agents, nil
}

func (a AgentRepositoryImpl) FindById(organizationId uuid.UUID, agentId string) (*Agent, error) {
	var agent Agent
	if result := a.Db.
		Scopes(BelongsToOrganization(organizationId)).
		Where("id = ?", agentId).First(&agent); result.Error != nil {
		return nil, result.Error
	}
	return &agent, nil
}

func (a AgentRepositoryImpl) FindByClientId(clientId string) (*Agent, error) {
	var agent Agent
	if result := a.Db.Where("oauth_client_id = ?", clientId).First(&agent); result.Error != nil {
		return &Agent{}, result.Error
	}
	return &agent, nil
}

func (a AgentRepositoryImpl) Create(agent *Agent) (*Agent, error) {
	err := a.Db.Transaction(func(tx *gorm.DB) error {
		// Create an OAuth application
		clientId := uuid.New()
		clientSecret := uuid.New()
		if err := a.ClientStore.Create(&models.Client{
			ID:     clientId.String(),
			Secret: clientSecret.String(),
			Domain: "",
			Public: false,
		}); err != nil {
			return err
		}

		// Create the agent resource
		agent.OauthClientID = clientId.String()
		result := a.Db.Create(agent)
		return result.Error
	})
	return agent, err
}

func (a AgentRepositoryImpl) Update(agent *Agent) (*Agent, error) {
	return nil, nil
}

func (a AgentRepositoryImpl) Delete(agentId string) error {
	return nil
}
