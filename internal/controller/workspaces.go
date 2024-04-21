package controller

import (
	"errors"
	"github.com/chushi-io/chushi/internal/helpers"
	"github.com/chushi-io/chushi/internal/http/response"
	"github.com/chushi-io/chushi/internal/resource/workspaces"
	"github.com/chushi-io/chushi/internal/service/file_manager"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"net/http"
)

type WorkspacesController struct {
	Repository  workspaces.WorkspacesRepository
	FileManager file_manager.FileManager
}

func NewWorkspacesController(repo workspaces.WorkspacesRepository, fileManager file_manager.FileManager) *WorkspacesController {
	return &WorkspacesController{
		Repository:  repo,
		FileManager: fileManager,
	}
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

func (ctrl *WorkspacesController) GetCloudWorkspace(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
	}

	workspace, err := ctrl.Repository.FindById(orgId, c.Param("workspace"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
	} else {
		c.JSON(http.StatusOK, workspace.ToCloud())
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
	var ws *workspaces.Workspace
	var err error
	if c.Param("organization") != "" {
		orgId, found := c.Get("organization")
		if !found || orgId == "" {
			c.AbortWithError(http.StatusForbidden, errors.New("organization not found"))
			return
		}
		orgUuid := orgId.(uuid.UUID)
		ws, err = ctrl.Repository.FindById(orgUuid, c.Param("workspace"))
		if err != nil {
			c.AbortWithError(http.StatusInternalServerError, err)
			return
		}
	} else {
		ws, err = ctrl.Repository.FindByWorkspaceId(c.Param("workspace"))
		if err != nil {
			c.AbortWithError(http.StatusInternalServerError, err)
			return
		}
	}

	if err := ctrl.Repository.Lock(ws); err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	c.JSON(http.StatusOK, ws.ToCloud())
}

func (ctrl *WorkspacesController) UnlockWorkspace(c *gin.Context) {
	var ws *workspaces.Workspace
	var err error
	if c.Param("organization") != "" {
		orgId, found := c.Get("organization")
		if !found || orgId == "" {
			c.AbortWithError(http.StatusForbidden, errors.New("organization not found"))
			return
		}
		orgUuid := orgId.(uuid.UUID)
		ws, err = ctrl.Repository.FindById(orgUuid, c.Param("workspace"))
		if err != nil {
			c.AbortWithError(http.StatusInternalServerError, err)
			return
		}
	} else {
		ws, err = ctrl.Repository.FindByWorkspaceId(c.Param("workspace"))
		if err != nil {
			c.AbortWithError(http.StatusInternalServerError, err)
			return
		}
	}

	if err := ctrl.Repository.Unlock(ws); err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	c.JSON(http.StatusOK, ws.ToCloud())
}

func (ctrl *WorkspacesController) GetState(c *gin.Context) {
	orgId := c.Param("organization")
	if orgId == "" {
		c.AbortWithError(http.StatusForbidden, errors.New("organization not found"))
		return
	}
	orgUuid, _ := uuid.Parse(orgId)

	workspace, err := ctrl.Repository.FindById(orgUuid, c.Param("workspace"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	state, err := ctrl.FileManager.FetchState(orgUuid, workspace.ID)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.Writer.Write(state)
	c.Status(http.StatusOK)
}

func (ctrl *WorkspacesController) UploadState(c *gin.Context) {
	var ws *workspaces.Workspace
	var orgUuid uuid.UUID
	var err error
	if c.Param("organization") != "" {
		orgId := c.Param("organization")
		if orgId == "" {
			c.AbortWithError(http.StatusForbidden, errors.New("organization not found"))
			return
		}
		orgUuid, _ := uuid.Parse(orgId)
		ws, err = ctrl.Repository.FindById(orgUuid, c.Param("workspace"))
		if err != nil {
			c.AbortWithError(http.StatusInternalServerError, err)
			return
		}
	} else {
		ws, err = ctrl.Repository.FindByWorkspaceId(c.Param("workspace"))
		if err != nil {
			c.AbortWithError(http.StatusInternalServerError, err)
			return
		}
	}
	err = ctrl.FileManager.UploadState(orgUuid, ws.ID, c.Request.Body)
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

func (ctrl *WorkspacesController) ListStateVersions(c *gin.Context) {
	orgId, found := c.Get("organization")
	if !found || orgId == "" {
		c.AbortWithError(http.StatusForbidden, errors.New("organization not found"))
		return
	}
	orgUuid := orgId.(uuid.UUID)

	workspace, err := ctrl.Repository.FindById(orgUuid, c.Param("workspace"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": []gin.H{
		{
			"id":   "sv-g4rqST72reoHMM5a",
			"type": "state-versions",
			"attributes": gin.H{
				"created-at":                     "2021-06-08T01:22:03.794Z",
				"size":                           940,
				"hosted-state-download-url":      "https://archivist.terraform.io/v1/object/...",
				"hosted-state-upload-url":        "null",
				"hosted-json-state-download-url": "https://archivist.terraform.io/v1/object/...",
				"hosted-json-state-upload-url":   "null",
				"status":                         "finalized",
				"intermediate":                   false,
				"modules":                        gin.H{},
				"providers":                      gin.H{},
				"resources":                      []gin.H{},
				"relationships":                  gin.H{},
				"workspace": gin.H{
					"data": gin.H{
						"id":   workspace.ID,
						"type": "workspaces",
					},
				},
				"outputs": gin.H{},
			},
		}}})
}

func (ctrl *WorkspacesController) CurrentStateVersion(c *gin.Context) {
	ws, err := ctrl.getWorkspaceFromContext(c)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, response.WorkspaceCurrentStateVersion(ws))
}

func (ctrl *WorkspacesController) CreateStateVersion(c *gin.Context) {
	ws, err := ctrl.getWorkspaceFromContext(c)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, response.WorkspaceStateVersion(ws))
}

func (ctrl *WorkspacesController) CreateConfigurationVersion(c *gin.Context) {
	ws, err := ctrl.getWorkspaceFromContext(c)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	configurationVersion := &workspaces.ConfigurationVersion{
		Source:      "tofu-api",
		Speculative: false,
		Status:      "pending",
		Provisional: false,
		WorkspaceId: ws.ID,
	}

	if err := ctrl.Repository.CreateConfigurationVersion(configurationVersion); err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, response.WorkspaceConfigurationVersion(ws, configurationVersion))
}

func (ctrl *WorkspacesController) UploadConfiguration(c *gin.Context) {
	ws, err := ctrl.getWorkspaceFromContext(c)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	version, err := ctrl.Repository.GetConfigurationVersion(c.Param("version"))
	if err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	if err := ctrl.FileManager.UploadConfiguration(ws.OrganizationID, version.ID, c.Request.Body); err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	version.Status = "uploaded"
	if err := ctrl.Repository.UpdateConfigurationVersion(version); err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, response.WorkspaceConfigurationVersion(ws, version))

}

func (ctrl *WorkspacesController) GetConfigurationVersion(c *gin.Context) {
	cv, err := ctrl.Repository.GetConfigurationVersion(c.Param("version"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	ws, err := ctrl.Repository.FindByWorkspaceId(cv.WorkspaceId.String())
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, response.WorkspaceConfigurationVersion(ws, cv))
}

func (ctrl *WorkspacesController) getWorkspaceFromContext(c *gin.Context) (*workspaces.Workspace, error) {
	if c.Param("organization") != "" {
		orgId, found := c.Get("organization")
		if !found {
			return nil, errors.New("organization not found")
		}

		orgUuid := orgId.(uuid.UUID)
		return ctrl.Repository.FindById(orgUuid, c.Param("workspace"))
	} else {
		// TODO: We should validate the organization ID at some point
		return ctrl.Repository.FindByWorkspaceId(c.Param("workspace"))
	}
}
