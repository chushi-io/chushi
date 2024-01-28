package workspaces

import (
	"github.com/gin-gonic/gin"
	"github.com/robwittman/chushi/internal/models"
	"net/http"
)

type Controller struct {
	Repository models.WorkspacesRepository
}

func (ctrl *Controller) CreateWorkspace(c *gin.Context) {

}

func (ctrl *Controller) ListWorkspaces(c *gin.Context) {
	org, _ := c.Get("organization")
	workspaces, _ := ctrl.Repository.FindAllForOrg(org.(*models.Organization).ID)
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

func (ctrl *Controller) LockWorkspace(c *gin.Context) {

}

func (ctrl *Controller) UnlockWorkspace(c *gin.Context) {

}

func (ctrl *Controller) GetState(c *gin.Context) {

}

func (ctrl *Controller) UploadState(c *gin.Context) {

}
