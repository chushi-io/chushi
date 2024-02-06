package controller

import (
	"context"
	"errors"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
	"github.com/gin-gonic/gin"
	"github.com/robwittman/chushi/internal/resource/workspaces"
	"github.com/robwittman/chushi/internal/server/helpers"
	"io"
	"net/http"
	"strings"
)

type WorkspacesController struct {
	Repository workspaces.WorkspacesRepository
	S3Client   *s3.Client
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

func (ctrl *WorkspacesController) UploadState(c *gin.Context) {
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
