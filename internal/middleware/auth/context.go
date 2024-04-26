package auth

import (
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/golang-jwt/jwt/v4"
)

type AuthenticationType string

const (
	AuthenticationTypeSession     AuthenticationType = "session"
	AuthenticationTypeAccessToken                    = "access_token"
	AuthenticationTypeAgentToken                     = "agent_token"
)

type Context struct {
	Type   AuthenticationType
	Claims *jwt.Claims

	User *organization.User
}

func NewContext(authType AuthenticationType, claims *jwt.Claims) *Context {
	return &Context{
		Type:   authType,
		Claims: claims,
	}
}

func NewContextForUser(authType AuthenticationType, claims *jwt.Claims, user *organization.User) *Context {
	ctx := NewContext(authType, claims)
	ctx.User = user
	return ctx
}
