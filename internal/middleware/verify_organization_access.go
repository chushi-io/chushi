package middleware

import (
	"context"
	"errors"
	"github.com/chushi-io/chushi/internal/resource/oauth"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/gin-gonic/gin"
	"github.com/go-oauth2/oauth2/v4/generates"
	"github.com/go-oauth2/oauth2/v4/server"
	"github.com/google/uuid"
	"github.com/volatiletech/authboss/v3"
	"net/http"
)

type OrganizationAccessMiddleware struct {
	OrganizationRepository organization.OrganizationRepository
	Auth                   *authboss.Authboss
	UserStore              *organization.UserStore
	OauthServer            *server.Server
	ClientStore            *oauth.ClientStore
}

func (oam *OrganizationAccessMiddleware) VerifyOrganizationAccess(c *gin.Context) {
	org, err := oam.OrganizationRepository.FindById(c.Param("organization"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	authType, authed := c.Get("auth_type")
	if !authed {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}

	switch authType {
	case "user":
	case "personal_access_token":
		oam.userAuth(c, org.ID)
		return
	case "token":
		oam.tokenAuth(c, org.ID)
		return
	}
}

func (oam *OrganizationAccessMiddleware) userAuth(c *gin.Context, orgId uuid.UUID) {
	obj, objExists := c.Get("user")
	if !objExists {
		c.AbortWithError(http.StatusUnauthorized, errors.New("invalid request"))
		return
	}

	u, ok := obj.(*organization.User)
	if !ok {
		c.AbortWithError(http.StatusUnauthorized, errors.New("invalid request"))
		return
	}

	if _, err := oam.OrganizationRepository.UserHasOrganization(u.ID.String(), orgId.String()); err != nil {
		c.AbortWithError(http.StatusUnauthorized, errors.New("invalid request"))
		return
	}
	c.Set("organization_id", orgId.String())
	//c.Set("organization", o)
}

func (oam *OrganizationAccessMiddleware) tokenAuth(c *gin.Context, orgId uuid.UUID) {
	rawClaims, found := c.Get("claims")
	if !found {
		c.AbortWithError(http.StatusUnauthorized, errors.New("invalid request"))
		return
	}

	claims, ok := rawClaims.(*generates.JWTAccessClaims)
	if !ok {
		c.AbortWithError(http.StatusUnauthorized, errors.New("invalid request"))
		return
	}

	client, err := oam.ClientStore.GetByID(context.TODO(), claims.Audience)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, errors.New("invalid request"))
		return
	}

	org, err := oam.OrganizationRepository.FindById(orgId.String())
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, errors.New("invalid request"))
		return
	}

	// For now, we'll assume we're an agent :shrug:
	c.Set("client_id", client.GetID())
	c.Set("organization_id", orgId.String())
	c.Set("organization", org)
	return
}
