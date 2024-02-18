package variables

import (
	"github.com/google/uuid"
	"time"
)

type VariableType string

const (
	VariableTypeOpenTofu    = "opentofu"
	VariableTypeEnvironment = "environment"
)

func ToVariableType(variableType string) VariableType {
	if variableType == VariableTypeEnvironment {
		return VariableTypeEnvironment
	}
	return VariableTypeOpenTofu
}

type Variable struct {
	ID        uuid.UUID  `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `sql:"index" json:"deleted_at"`

	Type           VariableType `json:"type"`
	Name           string       `json:"name"`
	Description    string       `json:"description"`
	Value          string       `json:"value"`
	Sensitive      bool         `json:"sensitive"`
	VariableSetID  uuid.UUID    `json:"variable_set_id,omitempty"`
	OrganizationID uuid.UUID    `json:"organization_id"`
}

type VariableSet struct {
	ID        uuid.UUID  `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `sql:"index" json:"deleted_at"`

	OrganizationID uuid.UUID   `json:"-"`
	Name           string      `json:"name"`
	Description    string      `json:"description"`
	AutoAttach     bool        `json:"auto_attach"`
	Priority       int32       `json:"priority"`
	Variables      []*Variable `json:"variables"`
}

type OrganizationVariableSet struct {
	OrganizationID uuid.UUID `gorm:"primaryKey"`
	VariableSetID  uuid.UUID `gorm:"primaryKey"`

	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `sql:"index" json:"deleted_at"`
}

type OrganizationVariable struct {
	OrganizationID uuid.UUID `gorm:"primaryKey"`
	VariableID     uuid.UUID `gorm:"primaryKey"`
}

type WorkspaceVariableSet struct {
	WorkspaceID   uuid.UUID `gorm:"primaryKey"`
	VariableSetID uuid.UUID `gorm:"primaryKey"`

	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `sql:"index" json:"deleted_at"`
}

type WorkspaceVariable struct {
	WorkspaceID uuid.UUID `gorm:"primaryKey"`
	VariableID  uuid.UUID `gorm:"primaryKey"`

	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `sql:"index" json:"deleted_at"`
}
