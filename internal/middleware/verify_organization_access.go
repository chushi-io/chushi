package middleware

import (
	"context"
	"errors"
	"fmt"
	"github.com/chushi-io/chushi/internal/resource/oauth"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/gin-gonic/gin"
	"github.com/go-oauth2/oauth2/v4/server"
	"github.com/golang-jwt/jwt/v4"
	"github.com/volatiletech/authboss/v3"
	"net/http"
	"os"
	"strings"
)

type OrganizationAccessMiddleware struct {
	OrganizationRepository organization.OrganizationRepository
	Auth                   *authboss.Authboss
	UserStore              *organization.UserStore
	OauthServer            *server.Server
	ClientStore            *oauth.ClientStore
}

func (oam *OrganizationAccessMiddleware) VerifyOrganizationAccess(c *gin.Context) {
	fmt.Println(c.Request.Header)
	org, err := oam.OrganizationRepository.FindById(c.Param("organization"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	userData, err := oam.Auth.CurrentUser(c.Request)
	if err != nil {
		if errors.Is(err, authboss.ErrUserNotFound) {
			fmt.Println("No user found, falling back to token authentication")
			authenticated, err := oam.handleToken(c)
			if !authenticated {
				c.AbortWithError(http.StatusUnauthorized, err)
				return
			} else {
				c.Set("organization", org)
			}
		} else {
			fmt.Println("No user attached to request")
			c.AbortWithError(http.StatusUnauthorized, err)
			return
		}
	} else {
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
}

func (oam *OrganizationAccessMiddleware) handleToken(c *gin.Context) (bool, error) {
	bearerToken := c.Request.Header.Get("Authorization")
	if bearerToken == "" {
		return false, errors.New("no token found")
	}
	authToken, _ := strings.CutPrefix(bearerToken, "Bearer ")

	fmt.Println(authToken)
	token, err := jwt.ParseWithClaims(authToken, &jwt.RegisteredClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(os.Getenv("JWT_SECRET_KEY")), nil
	})
	if err != nil {
		return false, errors.New("invalid token")
	}

	claims := token.Claims.(*jwt.RegisteredClaims)
	// We have a token. Get the OAuth client
	client, err := oam.ClientStore.GetByID(context.TODO(), claims.Audience[0])
	if err != nil {
		return false, err
	}

	// For now, we'll assume we're an agent :shrug:
	c.Set("client_id", client.GetID())
	return true, nil
}
