package helpers

import (
	"errors"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func GetOrganizationId(c *gin.Context) (uuid.UUID, error) {
	org, exists := c.Get("organization")
	if !exists {
		return uuid.UUID{}, errors.New("organization ID not found")
	}

	return org.(*organization.Organization).ID, nil
}

func GetOrganization(c *gin.Context) *organization.Organization {
	org, _ := c.Get("organization")
	return org.(*organization.Organization)
}
