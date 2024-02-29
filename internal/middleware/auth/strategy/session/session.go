package session

import (
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/gin-gonic/gin"
	"github.com/volatiletech/authboss/v3"
	"net/http"
)

type Session struct {
	authboss  *authboss.Authboss
	userStore *organization.UserStore
}

func New(ab *authboss.Authboss, userStore *organization.UserStore) *Session {
	return &Session{
		authboss:  ab,
		userStore: userStore,
	}
}

func (a *Session) Evaluate(c *gin.Context) bool {
	_, err := a.authboss.CurrentUser(c.Request)
	return err == nil
}

func (a *Session) Handle(c *gin.Context) bool {
	userData, err := a.authboss.CurrentUser(c.Request)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return false
	}
	user, err := a.userStore.GetUserObject(userData.GetPID())
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return false
	}

	c.Set("user", user)
	c.Set("auth_type", "user")
	return true
}
