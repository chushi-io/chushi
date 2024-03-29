package server

import (
	"github.com/chushi-io/chushi/internal/middleware"
	"github.com/chushi-io/chushi/internal/middleware/auth"
	"github.com/chushi-io/chushi/internal/middleware/auth/strategy/session"
	"github.com/chushi-io/chushi/internal/middleware/auth/strategy/token"
	"github.com/chushi-io/chushi/internal/resource/oauth"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/chushi-io/chushi/internal/resource/run"
	"github.com/chushi-io/chushi/internal/resource/variables"
	"github.com/chushi-io/chushi/internal/resource/vcs_connection"
	"github.com/chushi-io/chushi/internal/resource/workspaces"
	"github.com/chushi-io/chushi/internal/server/adapter"
	"github.com/chushi-io/chushi/internal/server/config"
	"github.com/gin-contrib/requestid"
	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"net/http"
	"os"
	"strings"
)

func New(conf *config.Config) (*gin.Engine, error) {

	// Load and initialize our database
	gormConfig := &gorm.Config{}
	if os.Getenv("APP_ENV") == "development" {
		gormConfig.Logger = logger.Default.LogMode(logger.Info)
	} else {
		gin.SetMode(gin.ReleaseMode)
	}

	database, err := gorm.Open(postgres.Open(conf.DatabaseUri), gormConfig)
	if err != nil {
		return nil, err
	}

	if err := database.AutoMigrate(
		&workspaces.Workspace{},
		&variables.Variable{},
		&variables.VariableSet{},
		&variables.OrganizationVariable{},
		&variables.WorkspaceVariable{},
		&variables.WorkspaceVariableSet{},
		&variables.OrganizationVariableSet{},
		&organization.Organization{},
		&oauth.OauthClient{},
		&oauth.OauthToken{},
		&run.Run{},
		&organization.User{},
		&organization.OrganizationUser{},
		&vcs_connection.VcsConnection{},
	); err != nil {
		return nil, err
	}

	factory, err := NewFactory(database)
	if err != nil {
		return nil, err
	}

	workspaceCtrl := factory.NewWorkspaceController()
	organizationsCtrl := factory.NewOrganizationsController()
	authServer := factory.NewOauthServer()
	agentCtrl := factory.NewAgentsController()
	runsCtrl := factory.NewRunsController()
	vcsCtrl := factory.NewVcsConnectionsController()
	variablesCtrl := factory.NewVariablesController()
	variableSetsCtrl := factory.NewVariableSetsController()
	ab := factory.NewAuthBoss()
	meCtrl := factory.NewMeController(ab)

	middlewareFactory := auth.WithStrategies(
		session.New(ab, factory.NewUserStore()),
		token.New(os.Getenv("JWT_SECRET_KEY")),
	)

	r := gin.Default()
	r.UseH2C = true
	r.Use(requestid.New())
	r.Use(adapter.Wrap(ab.LoadClientStateMiddleware))

	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})

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
	state := r.Group("/:orgId/:workspace/state")
	state.Use(middleware.VerifyStateAccess(
		os.Getenv("JWT_SECRET_KEY"),
		factory.NewWorkspacesRepository(),
	))
	{
		state.GET("", workspaceCtrl.GetState)
		state.POST("", workspaceCtrl.UploadState)
		state.Handle("LOCK", "", workspaceCtrl.LockWorkspace)
		state.Handle("UNLOCK", "", workspaceCtrl.UnlockWorkspace)
	}

	v1api := r.Group("/api/v1")
	// Apply our auth to all API endpoints
	v1api.Use(middlewareFactory.Handle)

	v1api.GET("/orgs", organizationsCtrl.List)
	v1api.POST("/orgs", organizationsCtrl.Create)
	orgs := v1api.Group("/orgs/:organization")
	// Authorize any requests to access the specified organization
	orgs.Use(factory.NewOrganizationAccessMiddleware(ab, authServer).VerifyOrganizationAccess)
	{
		orgs.GET("", organizationsCtrl.Get)
		variables := orgs.Group("/variables")
		{
			variables.GET("", variablesCtrl.List)
			variables.POST("", variablesCtrl.Create)
			variables.GET(":variable", variablesCtrl.Get)
			variables.PUT(":variable", variablesCtrl.Update)
			variables.DELETE(":variable", variablesCtrl.Delete)
		}

		variableSets := orgs.Group("/variable_sets")
		{
			variableSets.GET("", variableSetsCtrl.List)
			variableSets.POST("", variableSetsCtrl.Create)
			variableSets.GET(":variable_set", variableSetsCtrl.Get)
			variableSets.PUT(":variable_set", variableSetsCtrl.Update)
			variableSets.DELETE(":variable_set", variableSetsCtrl.Delete)
			variableSetVariables := variableSets.Group(":variable_set/variables")
			{
				variableSetVariables.GET("", variablesCtrl.List)
				variableSetVariables.POST("", variablesCtrl.Create)
				variableSetVariables.GET(":variable", variablesCtrl.Get)
				variableSetVariables.PUT(":variable", variablesCtrl.Update)
				variableSetVariables.DELETE(":variable", variablesCtrl.Delete)
			}
		}
	}

	// Workspaces
	workspaces := orgs.Group("/workspaces")
	wam := &middleware.WorkspaceAccessMiddleware{}
	workspaces.Use(wam.VerifyWorkspaceAccess)
	{
		workspaces.POST("", workspaceCtrl.CreateWorkspace)
		workspaces.GET("", workspaceCtrl.ListWorkspaces)
		workspace := workspaces.Group("/:workspace")
		{
			workspace.GET("", workspaceCtrl.GetWorkspace)
			workspace.POST("", workspaceCtrl.UpdateWorkspace)
			workspace.DELETE("", workspaceCtrl.DeleteWorkspace)

			// HTTP Backend handlers

			runs := workspace.Group("/runs")
			{
				runs.GET("", runsCtrl.List)
				runs.POST("", runsCtrl.Create)
				runs.GET("/:run", notImplemented)
				runs.POST("/:run", notImplemented)
				runs.DELETE("/:run", notImplemented)
			}

			variables := workspace.Group("/variables")
			{
				variables.GET("", variablesCtrl.List)
				variables.POST("", variablesCtrl.Create)
				variables.GET(":variable", variablesCtrl.Get)
				variables.PUT(":variable", variablesCtrl.Update)
				variables.DELETE(":variable", variablesCtrl.Delete)
			}
		}
	}

	agents := orgs.Group("agents")
	{
		agents.GET("", agentCtrl.List)
		agents.POST("", agentCtrl.Create)
		agents.GET("/:agent", agentCtrl.Get)
		agents.POST("/:agent", notImplemented)
		agents.DELETE("/:agent", notImplemented)

		agentRuns := agents.Group("/:agent/runs")
		{
			agentRuns.Use(agentCtrl.AgentAccess)
			agentRuns.GET("", agentCtrl.GetRuns)
		}

		agents.POST("/:agent/runner_token", agentCtrl.GenerateRunnerToken)
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
		vcsConnections.GET("", vcsCtrl.List)
		vcsConnections.POST("", vcsCtrl.Create)
		vcsConnections.GET(":vcs_connection", vcsCtrl.Get)
		vcsConnections.GET(":vcs_connection/credentials", vcsCtrl.Credentials)
		vcsConnections.DELETE(":vcs_connection", vcsCtrl.Delete)
	}
	runs := orgs.Group("/runs")
	{
		runs.POST("", notImplemented)
		runs.GET("/:run", runsCtrl.Get)
		runs.POST("/:run", runsCtrl.Update)
		runs.POST("/:run/presigned_url", runsCtrl.GeneratePresignedUrl)
		runs.PUT("/:run/plan", runsCtrl.StorePlan).Use(middleware.VerifyStateAccess(
			os.Getenv("JWT_SECRET_KEY"),
			factory.NewWorkspacesRepository(),
		))
		runs.POST("/:run/apply", notImplemented)
		runs.POST("/:run/discard", notImplemented)
		runs.POST("/:run/cancel", notImplemented)
		runs.POST("/:run/logs", runsCtrl.SaveLogs)
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
		meApi.GET("orgs", meCtrl.ListOrganizations)
	}

	authGroup := r.Group("/auth")
	//Use(adapter.Wrap(confirm.Middleware(ab)))
	{
		authGroup.Any("*w", gin.WrapH(http.StripPrefix("/auth", ab.Config.Core.Router)))

	}

	v1auth := r.Group("/oauth/v1")
	{
		v1auth.GET("/authorize", func(c *gin.Context) {
			err := authServer.HandleAuthorizeRequest(c.Writer, c.Request)
			if err != nil {
				c.AbortWithError(http.StatusBadRequest, err)
			}
		})
		v1auth.POST("/token", func(c *gin.Context) {
			authServer.HandleTokenRequest(c.Writer, c.Request)
		})
	}

	r.Static("/ui", "./ui/build")
	r.NoRoute(func(c *gin.Context) {
		if strings.HasPrefix(c.Request.URL.Path, "/ui") {
			c.File("./ui/build/index.html")
		} else {
			c.AbortWithStatus(http.StatusNotFound)
		}
	})

	grpcApi := r.Group("/grpc")
	{
		grpcApi.Any(factory.NewGrpcRunsServer())
		grpcApi.Any(factory.NewGrpcLogsServer())
		grpcApi.Any(factory.NewGrpcPlansServer())
	}

	return r, nil
}

func notImplemented(c *gin.Context) {
	c.AbortWithStatus(501)
}
