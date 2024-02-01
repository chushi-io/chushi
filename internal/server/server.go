package server

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/robwittman/chushi/internal/models"
	"github.com/robwittman/chushi/internal/server/config"
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
	if err := models.Setup(database); err != nil {
		return nil, err
	}

	factory := &Factory{Database: database}
	workspaceCtrl := factory.NewWorkspaceController()
	organizationsCtrl := factory.NewOrganizationsController()
	authServer := factory.NewOauthServer()

	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})

	r.GET("/.well-known/terraform.json", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"modules.v1":   "/api/v1/registry/modules",
			"providers.v1": "/api/v1/registry/providers",
			"motd.v1":      "",
			"state.v2":     "/api/v1",
			"tfe.v2":       "/api/v1",
			"tfe.v2.1":     "/api/v1",
			"versions.v1":  "/api/v1/versions/",
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
			workspace.PATCH("", workspaceCtrl.UpdateWorkspace)
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
		}
	}

	agents := orgs.Group("agents")
	{
		agents.GET("", notImplemented)
		agents.POST("", notImplemented)
		agents.GET("/:agent", notImplemented)
		agents.POST("/:agent", notImplemented)
		agents.DELETE("/:agent", notImplemented)
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
		runs.GET("/:run_id", notImplemented)
		runs.POST("/:run_id/apply", notImplemented)
		runs.POST("/:run_id/discard", notImplemented)
		runs.POST("/:run_id/cancel", notImplemented)
	}

	webhooks := orgs.Group("/webhooks")
	{
		provider := webhooks.Group("/:provider")
		{
			provider.POST("/events", notImplemented)
		}
	}

	v1auth := r.Group("/auth/v1")
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
	return r, nil
}

func notImplemented(c *gin.Context) {
	c.AbortWithStatus(501)
}
