package controller

import (
	"github.com/chushi-io/chushi/internal/helpers"
	"github.com/chushi-io/chushi/internal/resource/run"
	"github.com/chushi-io/chushi/internal/resource/workspaces"
	"github.com/chushi-io/chushi/internal/service/file_manager"
	"github.com/chushi-io/chushi/internal/service/run_manager"
	"github.com/chushi-io/chushi/pkg/types"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"net/http"
	"time"
)

type RunsController struct {
	Runs        run.RunRepository
	Workspaces  workspaces.WorkspacesRepository
	RunManager  run_manager.RunManager
	FileManager file_manager.FileManager
}

func (ctrl *RunsController) List(c *gin.Context) {
	params := &run.RunListParams{
		OrganizationId: helpers.GetOrganization(c).ID,
	}
	if workspaceId := c.Param("workspace"); workspaceId != "" {
		params.WorkspaceId = workspaceId
	}
	if status := c.Query("status"); status != "" {
		runStatus, _ := types.ToRunStatus(status)
		params.Status = runStatus
	}
	runs, err := ctrl.Runs.List(params)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"runs": runs,
	})
}

type CreateRunInput struct {
	Operation string `json:"operation"`
}

func (ctrl *RunsController) Create(c *gin.Context) {
	org := helpers.GetOrganization(c)

	var params CreateRunInput
	if err := c.ShouldBindJSON(&params); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	r, err := ctrl.RunManager.CreateRun(&run_manager.CreateRunParams{
		OrganizationId: org.ID,
		WorkspaceId:    uuid.MustParse(c.Param("workspace")),
		Operation:      params.Operation,
	})

	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"run": r.Run})
}

func (ctrl *RunsController) SaveLogs(c *gin.Context) {
	org := helpers.GetOrganization(c)
	var err error
	var runId *types.UuidOrString
	if runId, err = types.FromString(c.Param("run")); err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}
	r, err := ctrl.Runs.Get(runId)
	if err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	err = ctrl.FileManager.UploadLogs(org.ID, r.ID, c.Request.Body)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.Status(http.StatusOK)
}

func (ctrl *RunsController) Update(c *gin.Context) {
	var params run.UpdateRunParams
	var err error
	var runId *types.UuidOrString

	if err = c.ShouldBindJSON(&params); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if runId, err = types.FromString(c.Param("run")); err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	r, err := ctrl.Runs.Get(runId)
	if err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	if params.Add != 0 {
		r.Add = params.Add
	}
	if params.Change != 0 {
		r.Change = params.Change
	}
	if params.Remove != 0 {
		r.Destroy = params.Remove
	}
	if params.Status != "" {
		status, _ := types.ToRunStatus(params.Status)
		r.Status = status
		if params.Status == "completed" || params.Status == "failed" {
			completion := time.Now()
			r.CompletedAt = &completion
		}
	}

	if _, err = ctrl.Runs.Update(r); err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	} else {
		c.JSON(http.StatusOK, gin.H{"run": r})
	}
}

func (ctrl *RunsController) Get(c *gin.Context) {
	var err error
	var runId *types.UuidOrString
	if runId, err = types.FromString(c.Param("run")); err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	r, err := ctrl.Runs.Get(runId)
	if err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"run": r})
}

func (ctrl *RunsController) StorePlan(c *gin.Context) {
	org := helpers.GetOrganization(c)
	var err error
	var runId *types.UuidOrString
	if runId, err = types.FromString(c.Param("run")); err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	r, err := ctrl.Runs.Get(runId)
	if err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	if err = ctrl.FileManager.UploadPlan(org.ID, r.ID, c.Request.Body); err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.Status(http.StatusOK)
}

func (ctrl *RunsController) GeneratePresignedUrl(c *gin.Context) {
	org := helpers.GetOrganization(c)
	var err error
	var runId *types.UuidOrString
	if runId, err = types.FromString(c.Param("run")); err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	r, err := ctrl.Runs.Get(runId)
	if err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	url, err := ctrl.FileManager.PresignedPlanUrl(org.ID, r.ID)

	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"url": url,
	})
}
