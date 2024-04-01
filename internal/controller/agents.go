package controller

import (
	"fmt"
	"github.com/chushi-io/chushi/internal/helpers"
	"github.com/chushi-io/chushi/internal/resource/agent"
	"github.com/chushi-io/chushi/internal/resource/run"
	"github.com/chushi-io/chushi/internal/resource/workspaces"
	"github.com/chushi-io/chushi/internal/server/config"
	"github.com/chushi-io/chushi/pkg/types"
	"github.com/gin-gonic/gin"
	"github.com/go-oauth2/oauth2/v4/generates"
	"github.com/golang-jwt/jwt"
	"github.com/google/uuid"
	"net/http"
	"os"
	"strings"
)

type AgentsController struct {
	Repository          agent.AgentRepository
	RunsRepository      run.RunRepository
	WorkspaceRepository workspaces.WorkspacesRepository
	JwtSecretKey        string
}

func NewAgentsController(
	agentRepo agent.AgentRepository,
	runsRepo run.RunRepository,
	workspaceRepo workspaces.WorkspacesRepository,
	conf *config.Config,
) *AgentsController {
	return &AgentsController{
		Repository:          agentRepo,
		RunsRepository:      runsRepo,
		WorkspaceRepository: workspaceRepo,
		JwtSecretKey:        conf.JwtSecretKey,
	}
}

func (a *AgentsController) Middleware() []gin.HandlerFunc {
	return []gin.HandlerFunc{}
}

func (a *AgentsController) Routes() []types.Route {
	return []types.Route{
		types.RouteRegistration("GET", "", []gin.HandlerFunc{a.List}),
		types.RouteRegistration("POST", "", []gin.HandlerFunc{a.Create}),
		types.RouteRegistration("GET", "/:agent", []gin.HandlerFunc{a.Get}),
		types.RouteRegistration("POST", "/:agent", []gin.HandlerFunc{a.Update}),
		types.RouteRegistration("DELETE", "/:agent", []gin.HandlerFunc{a.Delete}),
		types.RouteRegistration("GET", "/:agent/runs", []gin.HandlerFunc{
			a.AgentAccess,
			a.GetRuns,
		}),
	}
}

func (ctrl *AgentsController) List(c *gin.Context) {
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

func (ctrl *AgentsController) Get(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}
	ag, err := ctrl.Repository.FindById(orgId, c.Param("agent"))
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	} else {
		c.JSON(http.StatusOK, gin.H{
			"agent": ag,
		})
	}
}

type CreateAgentRequest struct {
	Name string `json:"name"`
}

func (ctrl *AgentsController) Create(c *gin.Context) {
	orgId, err := helpers.GetOrganizationId(c)
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return
	}

	var params CreateAgentRequest
	if err := c.ShouldBindJSON(&params); err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	ag := &agent.Agent{
		OrganizationID: orgId,
		Name:           params.Name,
	}
	if _, err := ctrl.Repository.Create(ag); err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
	} else {
		c.JSON(http.StatusOK, gin.H{
			"agent": ag,
		})
	}
}

func (ctrl *AgentsController) Update(c *gin.Context) {

}

func (ctrl *AgentsController) Delete(c *gin.Context) {

}

func (ctrl *AgentsController) GetRuns(c *gin.Context) {

	params := &run.RunListParams{
		AgentId: c.Param("agent"),
	}
	if status := c.Query("status"); status != "" {
		runStatus, _ := types.ToRunStatus(status)
		params.Status = runStatus
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

func (ctrl *AgentsController) AgentAccess(c *gin.Context) {
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

type CreateRunnerTokenInput struct {
	WorkspaceId uuid.UUID `json:"workspace_id"`
	RunId       uuid.UUID `json:"run_id"`
}

func (ctrl *AgentsController) GenerateRunnerToken(c *gin.Context) {
	org := helpers.GetOrganization(c)

	// Verify the agent / runner can access the workspace
	var input CreateRunnerTokenInput
	if err := c.BindJSON(&input); err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	t := jwt.NewWithClaims(jwt.SigningMethodHS256,
		jwt.MapClaims{
			"workspace":    input.WorkspaceId.String(),
			"run":          input.RunId.String(),
			"organization": org.ID.String(),
		})
	s, err := t.SignedString([]byte(ctrl.JwtSecretKey))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"token": s,
	})
}
