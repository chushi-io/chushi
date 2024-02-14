package controller

import (
	"github.com/chushi-io/chushi/internal/resource/vcs_connection"
	"github.com/chushi-io/chushi/internal/server/helpers"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"net/http"
)

type VcsConnectionsController struct {
	Repository vcs_connection.Repository
}

func (ctrl *VcsConnectionsController) List(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}

	connections, err := ctrl.Repository.List(orgId)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"vcs_connections": connections,
	})
}

func (ctrl *VcsConnectionsController) Get(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}

	connectionId, err := uuid.Parse(c.Param("vcs_connection"))
	if err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	connection, err := ctrl.Repository.Get(orgId, connectionId)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"vcs_connection": connection,
	})
}

type VcsConnectionCreateInput struct {
	Type  string `json:"type"`
	Name  string `json:"name"`
	Token string `json:"token"`
}

func (ctrl *VcsConnectionsController) Create(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}

	var params VcsConnectionCreateInput
	if err := c.ShouldBindJSON(&params); err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	conn, err := ctrl.Repository.Create(&vcs_connection.VcsConnection{
		Name: params.Name,
		Github: vcs_connection.GithubConnection{
			Type:                params.Type,
			PersonalAccessToken: params.Token,
		},
		OrganizationID: orgId,
	})

	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"vcs_connection": conn,
	})
}

func (ctrl *VcsConnectionsController) Delete(c *gin.Context) {

}
