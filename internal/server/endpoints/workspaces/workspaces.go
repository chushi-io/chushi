package workspaces

import (
	"context"
	"errors"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
	"github.com/gin-gonic/gin"
	"github.com/robwittman/chushi/internal/models"
	"github.com/robwittman/chushi/internal/server/helpers"
	"io"
	"net/http"
	"strings"
)

type Controller struct {
	Repository models.WorkspacesRepository
	S3Client   *s3.Client
}

func (ctrl *Controller) CreateWorkspace(c *gin.Context) {
	var workspace models.Workspace

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

func (ctrl *Controller) ListWorkspaces(c *gin.Context) {
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

func (ctrl *Controller) GetWorkspace(c *gin.Context) {
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

func (ctrl *Controller) UpdateWorkspace(c *gin.Context) {
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

	var params models.UpdateWorkspaceParams
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

func (ctrl *Controller) DeleteWorkspace(c *gin.Context) {

}

func (ctrl *Controller) LockWorkspace(c *gin.Context) {
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

func (ctrl *Controller) UnlockWorkspace(c *gin.Context) {
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

func (ctrl *Controller) GetState(c *gin.Context) {
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

	output, err := ctrl.S3Client.GetObject(context.TODO(), &s3.GetObjectInput{
		Bucket: aws.String(orgId.String()),
		Key:    aws.String(workspace.ID.String()),
	})
	var nsk *types.NoSuchKey

	if err != nil && !errors.As(err, &nsk) {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	} else if err != nil {
		c.Status(http.StatusOK)
		return
	}

	defer output.Body.Close()
	b, err := io.ReadAll(output.Body)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.Writer.Write(b)
	c.Status(http.StatusOK)
}

func (ctrl *Controller) UploadState(c *gin.Context) {
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

	b, err := io.ReadAll(c.Request.Body)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	reader := strings.NewReader(string(b))
	_, err = ctrl.S3Client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(orgId.String()),
		Key:    aws.String(workspace.ID.String()),
		Body:   reader,
	})
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.Status(http.StatusOK)
}
