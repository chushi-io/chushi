package runs

import (
	"bytes"
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
	"time"
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
	if workspaceId := c.Param("workspace"); workspaceId != "" {
		params.WorkspaceId = workspaceId
	}
	if status := c.Query("status"); status != "" {
		params.Status = status
	}
	fmt.Println(params)
	runs, err := ctrl.Runs.List(params)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"runs": runs,
	})
}

type CreateRunRequest struct {
	Operation string `json:"operation"`
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

	var params CreateRunRequest
	if err := c.ShouldBindJSON(&params); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	run := &models.Run{
		Workspace: *workspace,
		AgentID:   workspace.AgentID,
		Status:    "pending",
		Operation: params.Operation,
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
		Key:    aws.String(fmt.Sprintf("runs/%s/logs", run.ID.String())),
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
	if params.Status != "" {
		run.Status = params.Status
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

func (ctrl *Controller) Get(c *gin.Context) {
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

func (ctrl *Controller) StorePlan(c *gin.Context) {
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
	_, err = ctrl.S3Client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(orgId.String()),
		Key:    aws.String(fmt.Sprintf("runs/%s/plan", run.ID.String())),
		Body:   bytes.NewReader(b),
	})
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.Status(http.StatusOK)
}

func (ctrl *Controller) GeneratePresignedUrl(c *gin.Context) {
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
