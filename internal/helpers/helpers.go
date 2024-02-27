package helpers

import (
	"errors"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"net/http"
	"strings"
)

func GetOrganizationId(c *gin.Context) (uuid.UUID, error) {
	org, exists := c.Get("organization")
	if !exists {
		return uuid.UUID{}, errors.New("organization ID not found")
	}

	return org.(*organization.Organization).ID, nil
}

func GetOrganization(c *gin.Context) *organization.Organization {
	org, exists := c.Get("organization")
	if !exists {
		c.AbortWithError(http.StatusUnauthorized, errors.New("unauthorized"))
		return nil
	}
	return org.(*organization.Organization)
}

func GetUuid(input string) (uuid.UUID, error) {
	uid, err := uuid.Parse(input)
	return uid, err
}

func GetTokenFromHeader(header string) (string, error) {
	if !strings.HasPrefix(header, "Bearer ") {
		return "", errors.New("invalid header provided")
	}
	authToken, _ := strings.CutPrefix(header, "Bearer ")
	return authToken, nil
}
