package personal_access_token

import (
	"github.com/chushi-io/chushi/internal/resource/access_token"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"strings"
)

type PersonalAccessToken struct {
	AccessTokens access_token.Repository
	UserRepo     organization.UserRepository
}

func New(repo access_token.Repository, userRepo organization.UserRepository) *PersonalAccessToken {
	return &PersonalAccessToken{AccessTokens: repo, UserRepo: userRepo}
}

func (t PersonalAccessToken) Evaluate(c *gin.Context) bool {
	bearerToken := c.Request.Header.Get("Authorization")
	if bearerToken == "" {
		return false
	}

	authToken, _ := strings.CutPrefix(bearerToken, "Bearer ")
	_, err := uuid.Parse(authToken)
	return err == nil
}

func (t PersonalAccessToken) Handle(c *gin.Context) bool {
	bearerToken := c.Request.Header.Get("Authorization")
	if bearerToken == "" {
		return false
	}
	authToken, _ := strings.CutPrefix(bearerToken, "Bearer ")

	_, err := uuid.Parse(authToken)
	if err != nil {
		return false
	}
	// We have a UUID
	accessToken, err := t.AccessTokens.FindByToken(authToken)
	if err != nil {
		return false
	}

	// We have an ID, need to get the user object
	user, err := t.UserRepo.Find(accessToken.UserId)
	if err != nil {
		return false
	}
	c.Set("user", user)
	c.Set("auth_type", "personal_access_token")
	return true
}
