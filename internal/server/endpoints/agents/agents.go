package agents

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/go-oauth2/oauth2/v4/generates"
	"github.com/golang-jwt/jwt"
	"github.com/robwittman/chushi/internal/models"
	"github.com/robwittman/chushi/internal/server/helpers"
	"net/http"
	"os"
	"strings"
)

type Controller struct {
	Repository          models.AgentRepository
	RunsRepository      models.RunRepository
	WorkspaceRepository models.WorkspacesRepository
}

func (ctrl *Controller) List(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}
	agents, err := ctrl.Repository.List(orgId)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
	} else {
		c.JSON(http.StatusOK, gin.H{
			"agents": agents,
		})
	}
}

func (ctrl *Controller) Get(c *gin.Context) {

}

func (ctrl *Controller) Create(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}
	agent := &models.Agent{
		OrganizationID: orgId,
	}
	if _, err := ctrl.Repository.Create(agent); err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
	} else {
		c.JSON(http.StatusOK, gin.H{
			"agent": agent,
		})
	}

}

func (ctrl *Controller) Update(c *gin.Context) {

}

func (ctrl *Controller) Delete(c *gin.Context) {

}

func (ctrl *Controller) GetRuns(c *gin.Context) {

	params := &models.RunListParams{
		AgentId: c.Param("agent"),
	}
	if status := c.Query("status"); status != "" {
		params.Status = status
	}
	runs, err := ctrl.RunsRepository.List(params)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"runs": runs,
	})
}

func (ctrl *Controller) AgentAccess(c *gin.Context) {
	input := c.Request.Header.Get("Authorization")
	if input == "" {
		c.AbortWithStatus(http.StatusForbidden)
		return
	}

	input, _ = strings.CutPrefix(input, "Bearer ")

	token, err := jwt.ParseWithClaims(input, &generates.JWTAccessClaims{}, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("parse error")
		}
		return []byte(os.Getenv("JWT_SECRET_KEY")), nil
	})
	if err != nil {
		c.AbortWithStatus(http.StatusUnauthorized)
		return
	}
	claims := token.Claims.(*generates.JWTAccessClaims)

	if _, err := ctrl.Repository.FindByClientId(claims.Audience); err != nil {
		c.AbortWithStatus(http.StatusUnauthorized)
		return
	}
}
