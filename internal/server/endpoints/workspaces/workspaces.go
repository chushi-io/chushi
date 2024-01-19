package workspaces

import (
	"github.com/gin-gonic/gin"
	"github.com/robwittman/chushi/internal/models"
	"net/http"
)

type Controller struct {
}

func (ctrl *Controller) CreateWorkspace(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"workspaces": []models.Workspace{},
	})
}

func (ctrl *Controller) ListWorkspaces(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"workspaces": []models.Workspace{},
	})
}

func (ctrl *Controller) GetWorkspace(c *gin.Context) {

}

func (ctrl *Controller) UpdateWorkspace(c *gin.Context) {

}

func (ctrl *Controller) DeleteWorkspace(c *gin.Context) {

}
