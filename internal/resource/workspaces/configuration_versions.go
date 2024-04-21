package workspaces

import (
	"github.com/google/uuid"
	"time"
)

type ConfigurationVersion struct {
	ID uuid.UUID `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`

	Source      string    `json:"source"`
	Speculative bool      `json:"speculative"`
	Status      string    `json:"status"`
	UploadUrl   string    `json:"upload_url"`
	Provisional bool      `json:"provisional"`
	WorkspaceId uuid.UUID `json:"-"`

	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `sql:"index" json:"deleted_at"`
}
