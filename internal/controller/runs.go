package controller

import (
	"context"
	"fmt"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/robwittman/chushi/internal/resource/run"
	"github.com/robwittman/chushi/internal/resource/workspaces"
	"github.com/robwittman/chushi/internal/server/helpers"
	"github.com/robwittman/chushi/internal/service/file_manager"
	"github.com/robwittman/chushi/internal/service/run_manager"
	"github.com/robwittman/chushi/pkg/types"
	"io"
	"net/http"
	"strings"
	"time"
)

type RunsController struct {
	Runs        run.RunRepository
	Workspaces  workspaces.WorkspacesRepository
	S3Client    *s3.Client
	RunManager  run_manager.RunManager
	FileManager file_manager.FileManager
}

func (ctrl *RunsController) List(c *gin.Context) {
	//orgId, err := helpers.GetOrganizationId(c)
	//if err != nil {
	//	c.AbortWithError(http.StatusUnauthorized, err)
	//	return
	//}

	params := &run.RunListParams{}
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

	c.JSON(http.StatusOK, gin.H{"run": r})
}

func (ctrl *RunsController) SaveLogs(c *gin.Context) {
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
		Key:    aws.String(fmt.Sprintf("runs/%s/logs", run.ID.String())),
		Body:   reader,
	})
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.Status(http.StatusOK)
}

func (ctrl *RunsController) Update(c *gin.Context) {
	var params run.UpdateRunParams
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
	if params.Status != "" {
		status, _ := types.ToRunStatus(params.Status)
		run.Status = status
		if params.Status == "completed" || params.Status == "failed" {
			completion := time.Now()
			run.CompletedAt = &completion
		}
	}

	if _, err = ctrl.Runs.Update(run); err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	} else {
		c.JSON(http.StatusOK, gin.H{"run": run})
	}
}

func (ctrl *RunsController) Get(c *gin.Context) {
	//orgId, err := helpers.GetOrganizationId(c)
	//if err != nil {
	//	c.AbortWithError(http.StatusUnauthorized, err)
	//	return
	//}

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
	c.JSON(http.StatusOK, gin.H{"run": run})
}

func (ctrl *RunsController) StorePlan(c *gin.Context) {
	org := helpers.GetOrganization(c)

	runId, err := uuid.Parse(c.Param("run"))
	if err != nil {
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

	presignClient := s3.NewPresignClient(ctrl.S3Client)
	request, err := presignClient.PresignPutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(orgId.String()),
		Key:    aws.String(fmt.Sprintf("runs/%s/plan", run.ID.String())),
	}, func(opts *s3.PresignOptions) {
		opts.Expires = time.Duration(300 * int64(time.Second))
		opts.ClientOptions = []func(*s3.Options){
			func(options *s3.Options) {
				options.BaseEndpoint = aws.String("http://host.minikube.internal:9000")
			},
		}
	})

	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"url": request.URL,
	})
}
