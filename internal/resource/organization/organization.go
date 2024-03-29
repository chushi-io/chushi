package organization

import (
	"github.com/google/uuid"
	"time"
)

type OrganizationType string

const (
	OrganizationTypePersonal OrganizationType = "personal"
	OrganizationTypeTeam                      = "team"
	OrganizationTypeBusiness                  = "business"
)

type Organization struct {
	ID        uuid.UUID        `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`
	CreatedAt time.Time        `json:"created_at"`
	UpdatedAt time.Time        `json:"updated_at"`
	DeletedAt *time.Time       `sql:"index" json:"deleted_at"`
	Name      string           `json:"name" gorm:"index:idx_name,unique;not_null"`
	Type      OrganizationType `json:"type"`
	Users     []*User          `json:"-" gorm:"many2many:organization_users;"`
	// Features for the organization
	AllowAutoCreateWorkspace bool      `json:"allow_auto_create_workspace"`
	DefaultAgentId           uuid.UUID `json:"default_agent_id"`
}

type OrganizationUser struct {
	OrganizationID uuid.UUID `gorm:"primaryKey"`
	UserID         uuid.UUID `gorm:"primaryKey"`
	Role           string
}
