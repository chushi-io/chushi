package auth

import (
	"github.com/golang-jwt/jwt/v4"
	"github.com/google/uuid"
)

type ChushiClaims struct {
	Permissions  []string                 `json:"permissions,omitempty"`
	Organization *ChushiOrganizationClaim `json:"organization,omitempty"`
	Team         *uuid.UUID               `json:"team,omitempty"`
	Run          *uuid.UUID               `json:"run,omitempty"`
	Workspace    *uuid.UUID               `json:"workspace,omitempty"`
	User         *ChushiUserClaim         `json:"user,omitempty"`
	jwt.RegisteredClaims
}

type ChushiOrganizationClaim struct {
	Name string    `json:"name,omitempty"`
	Id   uuid.UUID `json:"id,omitempty"`
}

type ChushiUserClaim struct {
	Email string    `json:"email,omitempty"`
	Id    uuid.UUID `json:"id,omitempty"`
}
