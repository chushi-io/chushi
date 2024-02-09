package agent

import (
	"github.com/chushi-io/chushi/internal/resource/oauth"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/google/uuid"
	"time"
)

type Agent struct {
	ID             uuid.UUID                 `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`
	CreatedAt      time.Time                 `json:"created_at"`
	UpdatedAt      time.Time                 `json:"updated_at"`
	DeletedAt      *time.Time                `sql:"index" json:"deleted_at"`
	Name           string                    `gorm:"index:idx_name,unique" json:"name"`
	OrganizationID uuid.UUID                 `gorm:"index:idx_name,unique" json:"organization_id"`
	Organization   organization.Organization `json:"-"`
	Status         string                    `json:"status"`
	OauthClientID  string                    `json:"oauth_client_id"`
	OauthClient    oauth.OauthClient         `json:"-"`
}
