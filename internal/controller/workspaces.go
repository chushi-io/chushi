package controller

import (
	"errors"
	"github.com/chushi-io/chushi/internal/helpers"
	"github.com/chushi-io/chushi/internal/resource/workspaces"
	"github.com/chushi-io/chushi/internal/service/file_manager"
	"github.com/gin-gonic/gin"
	"net/http"
)

type WorkspacesController struct {
	Repository  workspaces.WorkspacesRepository
	FileManager file_manager.FileManager
}

func (ctrl *WorkspacesController) CreateWorkspace(c *gin.Context) {
	var workspace workspaces.Workspace

	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
	}

	if err := c.ShouldBindJSON(&workspace); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	workspace.OrganizationID = orgId
	err = ctrl.Repository.Save(&workspace)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"workspace": workspace,
	})
}

func (ctrl *WorkspacesController) ListWorkspaces(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
	}
	workspaces, err := ctrl.Repository.FindAllForOrg(orgId)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
	} else {
		c.JSON(http.StatusOK, gin.H{
			"workspaces": workspaces,
		})
	}
}

func (ctrl *WorkspacesController) GetWorkspace(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
	}

	workspace, err := ctrl.Repository.FindById(orgId, c.Param("workspace"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
	} else {
		c.JSON(http.StatusOK, gin.H{
			"workspace": workspace,
		})
	}
}

func (ctrl *WorkspacesController) UpdateWorkspace(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}

	workspace, err := ctrl.Repository.FindById(orgId, c.Param("workspace"))
	if err != nil {
		c.AbortWithError(http.StatusNotFound, errors.New("not found"))
		return
	}

	var params workspaces.UpdateWorkspaceParams
	if err := c.BindJSON(&params); err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}
	// TODO: Verify ownership of the agent before attaching
	if params.AgentId != nil {
		workspace.AgentID = params.AgentId
	}

	if _, err = ctrl.Repository.Update(workspace); err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"workspace": workspace})

}

func (ctrl *WorkspacesController) DeleteWorkspace(c *gin.Context) {

}

func (ctrl *WorkspacesController) LockWorkspace(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}

	workspace, err := ctrl.Repository.FindById(orgId, c.Param("workspace"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	if err := ctrl.Repository.Lock(workspace); err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	c.Status(http.StatusOK)
}

func (ctrl *WorkspacesController) UnlockWorkspace(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}

	workspace, err := ctrl.Repository.FindById(orgId, c.Param("workspace"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	if err := ctrl.Repository.Unlock(workspace); err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	c.Status(http.StatusOK)
}

func (ctrl *WorkspacesController) GetState(c *gin.Context) {
	org := helpers.GetOrganization(c)

	workspace, err := ctrl.Repository.FindById(org.ID, c.Param("workspace"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	state, err := ctrl.FileManager.FetchState(org.ID, workspace.ID)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.Writer.Write(state)
	c.Status(http.StatusOK)
}

func (ctrl *WorkspacesController) UploadState(c *gin.Context) {
	org := helpers.GetOrganization(c)

	workspace, err := ctrl.Repository.FindById(org.ID, c.Param("workspace"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	err = ctrl.FileManager.UploadState(org.ID, workspace.ID, c.Request.Body)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.Status(http.StatusOK)
}

func (ctrl *WorkspacesController) ListVariables(c *gin.Context) {
	//org := helpers.GetOrganization(c)
	//
	//workspace, err := ctrl.Repository.FindById(org.ID, c.Param("workspace"))
	//if err != nil {
	//	c.AbortWithError(http.StatusInternalServerError, err)
	//	return
	//}

	//variables, err := ctrl.Repository.ListVariables(workspace.ID)
	//if err != nil {
	//	c.AbortWithError(http.StatusInternalServerError, err)
	//	return
	//}

	c.JSON(http.StatusOK, gin.H{
		"variables": map[string]interface{}{},
	})
}
