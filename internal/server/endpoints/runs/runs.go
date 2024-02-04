package runs

import (
	"context"
	"fmt"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/robwittman/chushi/internal/models"
	"github.com/robwittman/chushi/internal/server/helpers"
	"io"
	"net/http"
	"strings"
)

type Controller struct {
	Runs       models.RunRepository
	Workspaces models.WorkspacesRepository
	S3Client   *s3.Client
}

func (ctrl *Controller) List(c *gin.Context) {
	//orgId, err := helpers.GetOrganizationId(c)
	//if err != nil {
	//	c.AbortWithError(http.StatusUnauthorized, err)
	//	return
	//}

	params := &models.RunListParams{}
	runs, err := ctrl.Runs.List(params)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"runs": runs,
	})
}

func (ctrl *Controller) Create(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}

	workspace, err := ctrl.Workspaces.FindById(orgId, c.Param("workspace"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	run := &models.Run{
		Workspace: *workspace,
		Agent:     workspace.Agent,
		Status:    "pending",
	}

	if _, err := ctrl.Runs.Create(run); err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"run": run,
	})
}

func (ctrl *Controller) SaveLogs(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}

	runId, err := uuid.Parse(c.Param("run"))
	if err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}
	run, err := ctrl.Runs.Get(runId)
	if err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	b, err := io.ReadAll(c.Request.Body)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	reader := strings.NewReader(string(b))
	_, err = ctrl.S3Client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(orgId.String()),
		Key:    aws.String(fmt.Sprintf("runs/%s", run.ID.String())),
		Body:   reader,
	})
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.Status(http.StatusOK)
}

func (ctrl *Controller) Update(c *gin.Context) {
	var params models.UpdateRunParams
	if err := c.ShouldBindJSON(&params); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	runId, err := uuid.Parse(c.Param("run"))
	if err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}
	run, err := ctrl.Runs.Get(runId)
	if err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	if params.Add != 0 {
		run.Add = params.Add
	}
	if params.Change != 0 {
		run.Change = params.Change
	}
	if params.Remove != 0 {
		run.Destroy = params.Remove
	}

	if _, err = ctrl.Runs.Update(run); err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	} else {
		c.JSON(http.StatusOK, gin.H{"run": run})
	}
}
