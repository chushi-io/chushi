package scopes

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

func BelongsToOrganization(organizationId uuid.UUID) func(db *gorm.DB) *gorm.DB {
	return func(db *gorm.DB) *gorm.DB {
		return db.Where("organization_id = ?", organizationId.String())
	}
}
