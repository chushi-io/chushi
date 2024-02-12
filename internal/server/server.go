package server

import (
	"fmt"
	"github.com/chushi-io/chushi/internal/resource/oauth"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/chushi-io/chushi/internal/resource/run"
	"github.com/chushi-io/chushi/internal/resource/user"
	"github.com/chushi-io/chushi/internal/resource/workspaces"
	"github.com/chushi-io/chushi/internal/server/adapter"
	"github.com/chushi-io/chushi/internal/server/config"
	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"net/http"
)

func New(conf *config.Config) (*gin.Engine, error) {

	// Load and initialize our database
	database, err := gorm.Open(postgres.Open(conf.DatabaseUri), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return nil, err
	}

	if err := database.AutoMigrate(
		&workspaces.Workspace{},
		&organization.Organization{},
		&oauth.OauthClient{},
		&oauth.OauthToken{},
		&run.Run{},
		&user.User{},
	); err != nil {
		return nil, err
	}

	factory, err := NewFactory(database)
	if err != nil {
		return nil, err
	}
	workspaceCtrl := factory.NewWorkspaceController()
	organizationsCtrl := factory.NewOrganizationsController()
	//authServer := factory.NewOauthServer()
	agentCtrl := factory.NewAgentsController()
	runsCtrl := factory.NewRunsController()
	ab := factory.NewAuthBoss()

	r := gin.Default()
	//r.Use(adapter.Wrap(ab.LoadClientStateMiddleware))
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})

	v1api := r.Group("/api/v1")

	v1api.GET("/healthz", func(c *gin.Context) {
		c.Data(http.StatusOK, "", []byte("OK"))
	})
	v1api.GET("/readyz", func(c *gin.Context) {
		c.Data(http.StatusOK, "", []byte("OK"))
	})
	v1api.GET("/status", func(c *gin.Context) {
		c.Data(http.StatusOK, "", []byte("OK"))
	})
	v1api.GET("/metrics", notImplemented)

	v1api.Any("/terraform", func(context *gin.Context) {
		fmt.Println(context.Request)
	})
	v1api.Any("/lock", func(context *gin.Context) {
		fmt.Println(context.Request)
	})
	v1api.Any("/unlock", func(context *gin.Context) {
		fmt.Println(context.Request)
	})
	v1api.GET("/orgs", organizationsCtrl.List)
	v1api.POST("/orgs", organizationsCtrl.Create)
	orgs := v1api.Group("/orgs/:organization")
	{
		orgs.GET("", organizationsCtrl.Get)
	}
	orgs.Use(organizationsCtrl.SetContext)

	// Workspaces
	workspaces := orgs.Group("/workspaces")
	{
		workspaces.POST("", workspaceCtrl.CreateWorkspace)
		workspaces.GET("", workspaceCtrl.ListWorkspaces)
		workspace := workspaces.Group("/:workspace")
		{
			workspace.GET("", workspaceCtrl.GetWorkspace)
			workspace.POST("", workspaceCtrl.UpdateWorkspace)
			workspace.DELETE("", workspaceCtrl.DeleteWorkspace)
			workspace.GET("/variables", notImplemented)
			workspace.POST("/variables", notImplemented)
			workspace.PATCH("/variables/:variable", notImplemented)
			workspace.DELETE("/variables/:variable", notImplemented)

			// HTTP Backend handlers
			workspace.GET("/state", workspaceCtrl.GetState)
			workspace.POST("/state", workspaceCtrl.UploadState)
			workspace.Handle("LOCK", "", workspaceCtrl.LockWorkspace)
			workspace.Handle("UNLOCK", "", workspaceCtrl.UnlockWorkspace)

			runs := workspace.Group("/runs")
			{
				runs.GET("", runsCtrl.List)
				runs.POST("", runsCtrl.Create)
				runs.GET("/:run", notImplemented)
				runs.POST("/:run", notImplemented)
				runs.DELETE("/:run", notImplemented)
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

	runs := orgs.Group("/runs")
	{
		runs.POST("", notImplemented)
		runs.GET("/:run", runsCtrl.Get)
		runs.POST("/:run", runsCtrl.Update)
		runs.POST("/:run/presigned_url", runsCtrl.GeneratePresignedUrl)
		runs.PUT("/:run/plan", runsCtrl.StorePlan)
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

	authGroup := r.Group("/auth").Use(adapter.Wrap(ab.LoadClientStateMiddleware))
	{
		//authGroup.Use(adapter.Wrap(ab.LoadClientStateMiddleware))
		authGroup.Any("*w", gin.WrapH(http.StripPrefix("/auth", ab.Config.Core.Router)))
	}

	//v1auth := r.Group("/auth/v1")
	//{
	//	v1auth.GET("/authorize", func(c *gin.Context) {
	//		err := authServer.HandleAuthorizeRequest(c.Writer, c.Request)
	//		if err != nil {
	//			c.AbortWithError(http.StatusBadRequest, err)
	//		}
	//	})
	//	v1auth.POST("/token", func(c *gin.Context) {
	//		authServer.HandleTokenRequest(c.Writer, c.Request)
	//	})
	//}

	r.Static("/ui", "./ui/build")
	r.NoRoute(func(c *gin.Context) {
		c.File("./ui/build/index.html")
	})

	fmt.Printf("- ab.Config.Paths.RootURL: %s\n", ab.Config.Paths.RootURL)
	fmt.Printf("- ab.Config.Paths.Mount: %s\n", ab.Config.Paths.Mount)

	routes := r.Routes()
	for route := range routes {
		fmt.Printf("- %s\n", routes[route].Path)
	}

	return r, nil
}

func notImplemented(c *gin.Context) {
	c.AbortWithStatus(501)
}
