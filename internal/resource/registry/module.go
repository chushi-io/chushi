package registry

import (
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/google/uuid"
	"time"
)

type Module struct {
	ID             uuid.UUID                 `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`
	CreatedAt      time.Time                 `json:"created_at"`
	UpdatedAt      time.Time                 `json:"updated_at"`
	DeletedAt      *time.Time                `sql:"index" json:"deleted_at"`
	Namespace      string                    `json:"namespace"`
	Name           string                    `gorm:"index:idx_name,unique" json:"name"`
	Version        *ModuleVersion            `json:"current_version"`
	Versions       []ModuleVersion           `json:"versions,omitempty"`
	Provider       string                    `json:"provider"`
	Source         string                    `json:"source"`
	Description    string                    `json:"description"`
	OrganizationID uuid.UUID                 `gorm:"index:idx_name,unique" json:"organization_id"`
	Organization   organization.Organization `json:"-"`
}

type ModuleVersion struct {
	ID        uuid.UUID  `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `sql:"index" json:"deleted_at"`
	Version   string     `json:"version"`
	ModuleID  uuid.UUID  `json:"module_id"`
	Module    *Module    `json:"-"`
}

//  "id": "GoogleCloudPlatform/lb-http/google/1.0.4",
//      "owner": "",
//      "namespace": "GoogleCloudPlatform",
//      "name": "lb-http",
//      "version": "1.0.4",
//      "provider": "google",
//      "description": "Modular Global HTTP Load Balancer for GCE using forwarding rules.",
//      "source": "https://github.com/GoogleCloudPlatform/terraform-google-lb-http",
//      "published_at": "2017-10-17T01:22:17.792066Z",
//      "downloads": 213,
//      "verified": true
