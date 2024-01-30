package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
	"time"
)

type Base struct {
	ID        uuid.UUID  `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `sql:"index" json:"deleted_at"`
}

func BelongsToOrganization(organizationId uuid.UUID) func(db *gorm.DB) *gorm.DB {
	return func(db *gorm.DB) *gorm.DB {
		return db.Where("organization_id = ?", organizationId.String())
	}
}
