package middleware

import (
	"fmt"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/gin-gonic/gin"
	"github.com/volatiletech/authboss/v3"
	"net/http"
)

type OrganizationAccessMiddleware struct {
	OrganizationRepository organization.OrganizationRepository
	Auth                   *authboss.Authboss
	UserStore              *organization.UserStore
}

func (oam *OrganizationAccessMiddleware) VerifyOrganizationAccess(c *gin.Context) {
	org, err := oam.OrganizationRepository.FindById(c.Param("organization"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	userData, err := oam.Auth.CurrentUser(c.Request)
	if err != nil {
		fmt.Println("No user attached to request")
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}

	user, err := oam.UserStore.GetUserObject(userData.GetPID())
	if err != nil {
		fmt.Println("Unable to find user")
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}

	if _, err := oam.OrganizationRepository.UserHasOrganization(user.ID.String(), org.ID.String()); err != nil {
		c.AbortWithError(http.StatusNotFound, err)
		return
	}

	// They have access, set the org info
	c.Set("organization", org)
	c.Set("user_id", user.ID)
}
