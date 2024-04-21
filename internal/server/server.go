package server

import (
	"context"
	"fmt"
	"github.com/chushi-io/chushi/internal/controller"
	"github.com/chushi-io/chushi/internal/middleware"
	"github.com/chushi-io/chushi/internal/middleware/auth"
	"github.com/chushi-io/chushi/internal/middleware/auth/strategy/personal_access_token"
	"github.com/chushi-io/chushi/internal/middleware/auth/strategy/session"
	"github.com/chushi-io/chushi/internal/middleware/auth/strategy/token"
	"github.com/chushi-io/chushi/internal/resource/access_token"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/chushi-io/chushi/internal/resource/workspaces"
	"github.com/chushi-io/chushi/internal/server/adapter"
	"github.com/chushi-io/chushi/internal/server/config"
	"github.com/gin-contrib/requestid"
	"github.com/gin-gonic/gin"
	"github.com/go-oauth2/oauth2/v4/server"
	"github.com/volatiletech/authboss/v3"
	"go.uber.org/fx"
	"go.uber.org/zap"
	"net"
	"net/http"
	"strings"
)

type Params struct {
	fx.In
	Config                       *config.Config
	Logger                       *zap.Logger
	WorkspacesController         *controller.WorkspacesController
	OrganizationsController      *controller.OrganizationsController
	AgentsController             *controller.AgentsController
	RunsController               *controller.RunsController
	VcsController                *controller.VcsConnectionsController
	VariablesController          *controller.VariablesController
	VariablesSetsController      *controller.VariableSetsController
	MeController                 *controller.MeController
	AccessTokensController       *controller.AccessTokensController
	AuthServer                   *server.Server
	AuthBoss                     *authboss.Authboss
	UserStore                    *organization.UserStore
	WorkspacesRepository         workspaces.WorkspacesRepository
	OrganizationAccessMiddleware *middleware.OrganizationAccessMiddleware
	UserinfoMiddleware           *middleware.UserinfoMiddleware
	AccessTokensRepository       access_token.Repository
	UserRepository               organization.UserRepository
}

func New(params Params, lc fx.Lifecycle) (*gin.Engine, error) {

	middlewareFactory := auth.WithStrategies(
		session.New(params.AuthBoss, params.UserStore),
		token.New(params.Config.JwtSecretKey),
		personal_access_token.New(params.AccessTokensRepository, params.UserRepository),
	)

	r := gin.Default()
	//r.UseH2C = true
	r.Use(requestid.New())
	r.Use(adapter.Wrap(params.AuthBoss.LoadClientStateMiddleware))

	r.Handle("PRI", ":any", func(c *gin.Context) {
		c.Status(200)
	})
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})

	settings := r.Group("/settings")
	settings.Use(params.UserinfoMiddleware.Handle)
	{
		settings.GET("access_tokens", params.AccessTokensController.List)
		settings.POST("access_tokens", params.AccessTokensController.Create)
		settings.DELETE("access_tokens/:accessToken", params.AccessTokensController.Delete)
	}

	api := r.Group("/api")
	{
		api.GET("/healthz", func(c *gin.Context) {
			c.Data(http.StatusOK, "", []byte("OK"))
		})
		api.GET("/readyz", func(c *gin.Context) {
			c.Data(http.StatusOK, "", []byte("OK"))
		})
		api.GET("/status", func(c *gin.Context) {
			c.Data(http.StatusOK, "", []byte("OK"))
		})
		api.GET("/metrics", notImplemented)
	}

	// Hoist state to top level routing
	state := r.Group("/:organization/:workspace/state")
	state.Use(
		middleware.VerifyStateAccess(
			params.Config.JwtSecretKey,
			params.WorkspacesRepository,
		))
	{
		state.GET("", params.WorkspacesController.GetState)
		state.POST("", params.WorkspacesController.UploadState)
		state.Handle("LOCK", "", params.WorkspacesController.LockWorkspace)
		state.Handle("UNLOCK", "", params.WorkspacesController.UnlockWorkspace)
	}

	v1api := r.Group("/api/v1")
	// Apply our auth to all API endpoints
	v1api.Use(middlewareFactory.Handle)

	// Mappings to support opentofu cloud workspace
	r.GET("/.well-known/terraform.json", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"modules.v1": "/api/v1/registry/modules/", "providers.v1": "/api/v1/registry/providers/", "motd.v1": "/api/terraform/motd", "state.v2": "/api/v1/", "tfe.v2": "/api/v1/", "tfe.v2.1": "/api/v1/", "tfe.v2.2": "/api/v1/", "versions.v1": "https://checkpoint-api.hashicorp.com/v1/versions/"})
	})
	v1api.GET("/organizations/:organization", params.OrganizationsController.Get)
	v1api.GET("/organizations/:organization/entitlement-set", params.OrganizationsController.Entitlements)
	v1api.
		//Use(middleware.VerifyStateAccess(
		//	params.Config.JwtSecretKey,
		//	params.WorkspacesRepository,
		//)).
		Use(params.OrganizationsController.SetContext).
		Use(params.OrganizationAccessMiddleware.VerifyOrganizationAccess).
		GET("/organizations/:organization/workspaces/:workspace", params.WorkspacesController.GetCloudWorkspace)
	r.Use(func(c *gin.Context) {
		fmt.Println(c.Request.Header)
	})
	r.POST("/api/v1/workspaces/:workspace/actions/lock", params.WorkspacesController.LockWorkspace)
	r.POST("/api/v1/workspaces/:workspace/actions/unlock", params.WorkspacesController.UnlockWorkspace)
	r.GET("/api/v1/workspaces/:workspace/state-versions", params.WorkspacesController.ListStateVersions)
	r.GET("/api/v1/workspaces/:workspace/current-state-version", params.WorkspacesController.CurrentStateVersion)
	r.POST("/api/v1/workspaces/:workspace/state-versions", params.WorkspacesController.CreateStateVersion)
	r.POST("/api/v1/runs", params.RunsController.CloudCreate)
	r.GET("/api/v1/configuration-versions/:version", params.WorkspacesController.GetConfigurationVersion)
	r.POST("/api/v1/workspaces/:workspace/configuration-versions", params.WorkspacesController.CreateConfigurationVersion)
	r.PUT("/api/v1/workspaces/:workspace/configuration-versions/:version", params.WorkspacesController.UploadConfiguration)
	r.GET("/api/v1/runs/:run/run-events", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{})
	})
	r.GET("/api/v1/runs/:run", params.RunsController.CloudGet)
	r.GET("/api/v1/workspaces/:workspace/runs", params.RunsController.CloudList)
	r.GET("/api/v1/organizations/:organization/runs/queue", params.RunsController.CloudQueue)

	r.GET("/api/v1/ping", func(c *gin.Context) {
		c.Header("tfp-api-version", "2.6")
		c.Header("tfp-appname", "Chushi")
		c.Status(http.StatusOK)
	})
	v1api.GET("/orgs", params.OrganizationsController.List)
	v1api.POST("/orgs", params.OrganizationsController.Create)
	orgs := v1api.Group("/orgs/:organization")
	// Authorize any requests to access the specified organization
	orgs.
		Use(params.OrganizationsController.SetContext).
		Use(params.OrganizationAccessMiddleware.VerifyOrganizationAccess)
	{
		orgs.GET("", params.OrganizationsController.Get)
		variables := orgs.Group("/variables")
		{
			variables.GET("", params.VariablesController.List)
			variables.POST("", params.VariablesController.Create)
			variables.GET(":variable", params.VariablesController.Get)
			variables.PUT(":variable", params.VariablesController.Update)
			variables.DELETE(":variable", params.VariablesController.Delete)
		}

		variableSets := orgs.Group("/variable_sets")
		{
			variableSets.GET("", params.VariablesSetsController.List)
			variableSets.POST("", params.VariablesSetsController.Create)
			variableSets.GET(":variable_set", params.VariablesSetsController.Get)
			variableSets.PUT(":variable_set", params.VariablesSetsController.Update)
			variableSets.DELETE(":variable_set", params.VariablesSetsController.Delete)
			variableSetVariables := variableSets.Group(":variable_set/variables")
			{
				variableSetVariables.GET("", params.VariablesController.List)
				variableSetVariables.POST("", params.VariablesController.Create)
				variableSetVariables.GET(":variable", params.VariablesController.Get)
				variableSetVariables.PUT(":variable", params.VariablesController.Update)
				variableSetVariables.DELETE(":variable", params.VariablesController.Delete)
			}
		}
	}

	// Workspaces
	workspaces := orgs.Group("/workspaces")
	wam := &middleware.WorkspaceAccessMiddleware{}
	workspaces.Use(wam.VerifyWorkspaceAccess)
	{
		workspaces.POST("", params.WorkspacesController.CreateWorkspace)
		workspaces.GET("", params.WorkspacesController.ListWorkspaces)
		workspace := workspaces.Group("/:workspace")
		{
			workspace.GET("", params.WorkspacesController.GetWorkspace)
			workspace.POST("", params.WorkspacesController.UpdateWorkspace)
			workspace.DELETE("", params.WorkspacesController.DeleteWorkspace)

			// HTTP Backend handlers

			runs := workspace.Group("/runs")
			{
				runs.GET("", params.RunsController.List)
				runs.POST("", params.RunsController.Create)
				runs.GET("/:run", params.RunsController.Get)
				runs.POST("/:run", notImplemented)
				runs.DELETE("/:run", notImplemented)
			}

			variables := workspace.Group("/variables")
			{
				variables.GET("", params.VariablesController.List)
				variables.POST("", params.VariablesController.Create)
				variables.GET(":variable", params.VariablesController.Get)
				variables.PUT(":variable", params.VariablesController.Update)
				variables.DELETE(":variable", params.VariablesController.Delete)
			}
		}
	}

	agents := orgs.Group("agents")
	{
		agents.GET("", params.AgentsController.List)
		agents.POST("", params.AgentsController.Create)
		agents.GET("/:agent", params.AgentsController.Get)
		agents.POST("/:agent", notImplemented)
		agents.DELETE("/:agent", notImplemented)

		agentRuns := agents.Group("/:agent/runs")
		{
			agentRuns.Use(params.AgentsController.AgentAccess)
			agentRuns.GET("", params.AgentsController.GetRuns)
		}

		agents.POST("/:agent/runner_token", params.AgentsController.GenerateRunnerToken)
	}

	// Plans
	orgs.GET("/plans/:id", notImplemented)

	// Applies
	orgs.GET("/applies/:id", notImplemented)

	// Cost Estimates
	orgs.GET("/estimates/:id", notImplemented)

	// Registry (Modules / Providers)
	registry := orgs.Group("/registry/:id")
	{
		modules := registry.Group("/modules")
		{
			modules.GET("/:namespace/:name/:provider", notImplemented)
			modules.DELETE("/:namespace/:name/:provider", notImplemented)
			modules.POST("/:namespace/:name/:provider/versions", notImplemented)
			modules.DELETE("/:namespace/:name/:provider/:version", notImplemented)
		}
		providers := registry.Group("/providers")
		{
			providers.GET("", notImplemented)
			providers.POST("", notImplemented)
			providers.GET("/:namespace/:name", notImplemented)
			providers.DELETE("/:namespace/:name", notImplemented)
		}
	}

	vcsConnections := orgs.Group("/vcs_connections")
	{
		vcsConnections.GET("", params.VcsController.List)
		vcsConnections.POST("", params.VcsController.Create)
		vcsConnections.GET(":vcs_connection", params.VcsController.Get)
		vcsConnections.GET(":vcs_connection/credentials", params.VcsController.Credentials)
		vcsConnections.DELETE(":vcs_connection", params.VcsController.Delete)
	}
	runs := orgs.Group("/runs")
	{
		runs.POST("", notImplemented)
		runs.GET("/:run", params.RunsController.Get)
		runs.POST("/:run", params.RunsController.Update)
		runs.POST("/:run/presigned_url", params.RunsController.GeneratePresignedUrl)
		runs.PUT("/:run/plan", params.RunsController.StorePlan).Use(middleware.VerifyStateAccess(
			params.Config.JwtSecretKey,
			params.WorkspacesRepository,
		))
		runs.POST("/:run/apply", notImplemented)
		runs.POST("/:run/discard", notImplemented)
		runs.POST("/:run/cancel", notImplemented)
		runs.POST("/:run/logs", params.RunsController.SaveLogs)
	}

	webhooks := orgs.Group("/webhooks")
	{
		provider := webhooks.Group("/:provider")
		{
			provider.POST("/events", notImplemented)
		}
	}

	meApi := r.Group("me")
	{
		meApi.GET("orgs", params.MeController.ListOrganizations)
	}

	authGroup := r.Group("/auth")
	//Use(adapter.Wrap(confirm.Middleware(ab)))
	{
		authGroup.Any("*w", gin.WrapH(http.StripPrefix("/auth", params.AuthBoss.Config.Core.Router)))
	}

	v1auth := r.Group("/oauth/v1")
	{
		v1auth.GET("/authorize", func(c *gin.Context) {
			err := params.AuthServer.HandleAuthorizeRequest(c.Writer, c.Request)
			if err != nil {
				c.AbortWithError(http.StatusBadRequest, err)
			}
		})
		v1auth.POST("/token", func(c *gin.Context) {
			params.AuthServer.HandleTokenRequest(c.Writer, c.Request)
		})
	}

	r.Static("/ui", "./ui/build")
	r.NoRoute(func(c *gin.Context) {
		if strings.HasPrefix(c.Request.URL.Path, "/ui") {
			c.File("./ui/build/index.html")
		} else if c.Request.Method == "PRI" {
			c.AbortWithStatus(http.StatusOK)
		} else {
			c.AbortWithStatus(http.StatusNotFound)
		}
	})

	srv := &http.Server{Addr: ":8080", Handler: r}

	lc.Append(fx.Hook{
		OnStart: func(ctx context.Context) error {

			ln, err := net.Listen("tcp", srv.Addr)
			if err != nil {
				return err
			}
			params.Logger.Info("Starting HTTP server")
			go func() {
				err := srv.Serve(ln)
				if err != nil {
					params.Logger.Fatal(err.Error())
				}
			}()
			return nil
		},
		OnStop: func(ctx context.Context) error {
			return srv.Shutdown(ctx)
		},
	})
	return r, nil
}

func notImplemented(c *gin.Context) {
	c.AbortWithStatus(501)
}
