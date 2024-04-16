package middleware

import (
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/gin-gonic/gin"
	"github.com/volatiletech/authboss/v3"
	"net/http"
)

type UserinfoMiddleware struct {
	Auth      *authboss.Authboss
	UserStore *organization.UserStore
}

func NewUserinfoMiddleware(auth *authboss.Authboss, userStore *organization.UserStore) *UserinfoMiddleware {
	return &UserinfoMiddleware{
		Auth:      auth,
		UserStore: userStore,
	}
}

func (uim *UserinfoMiddleware) Handle(c *gin.Context) {
	currentUser, err := uim.Auth.CurrentUser(c.Request)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}

	user, err := uim.UserStore.GetUserObject(currentUser.GetPID())
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}

	c.Set("user", user)
}
