package helpers

import (
	"errors"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/robwittman/chushi/internal/resource/organization"
)

func GetOrganizationId(c *gin.Context) (uuid.UUID, error) {
	org, exists := c.Get("organization")
	if !exists {
		return uuid.UUID{}, errors.New("organization ID not found")
	}

	return org.(*organization.Organization).ID, nil
}
