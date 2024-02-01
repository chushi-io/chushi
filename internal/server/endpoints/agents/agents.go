package agents

import (
	"github.com/gin-gonic/gin"
	"github.com/robwittman/chushi/internal/models"
	"github.com/robwittman/chushi/internal/server/helpers"
	"net/http"
)

type Controller struct {
	Repository models.AgentRepository
}

func (ctrl *Controller) List(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}
	agents, err := ctrl.Repository.List(orgId)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
	} else {
		c.JSON(http.StatusOK, gin.H{
			"agents": agents,
		})
	}
}

func (ctrl *Controller) Get(c *gin.Context) {

}

func (ctrl *Controller) Create(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}
	agent := &models.Agent{
		OrganizationID: orgId,
	}
	if _, err := ctrl.Repository.Create(agent); err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
	} else {
		c.JSON(http.StatusOK, gin.H{
			"agent": agent,
		})
	}

}

func (ctrl *Controller) Update(c *gin.Context) {

}

func (ctrl *Controller) Delete(c *gin.Context) {

}

func (ctrl *Controller) GetQueue(c *gin.Context) {
	// Validate the token
	// Verify the agent
	// Get the first workspace that needs to be ran
	// If none, return 204
	// return the workspace object
}
