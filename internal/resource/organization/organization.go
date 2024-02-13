package organization

import (
	"github.com/google/uuid"
	"time"
)

type Organization struct {
	ID        uuid.UUID  `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `sql:"index" json:"deleted_at"`
	Name      string     `json:"name" gorm:"index:idx_name,unique;not_null"`
	Users     []*User    `gorm:"many2many:user_languages;"`
	// Features for the organization
	AllowAutoCreateWorkspace bool `json:"allow_auto_create_workspace"`
}
