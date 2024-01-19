package server

import (
	"github.com/gin-gonic/gin"
	"github.com/robwittman/chushi/internal/models"
	"github.com/robwittman/chushi/internal/server/config"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"net/http"
)

func New(conf *config.Config) (*gin.Engine, error) {

	// Load and initialize our database
	database, err := gorm.Open(postgres.Open(conf.DatabaseUri), &gorm.Config{})
	if err != nil {
		return nil, err
	}
	if err := models.Setup(database); err != nil {
		return nil, err
	}

	factory := &Factory{}

	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})

	r.GET("/healthz", func(c *gin.Context) {
		c.Data(http.StatusOK, "", []byte("OK"))
	})
	r.GET("/readyz", func(c *gin.Context) {
		c.Data(http.StatusOK, "", []byte("OK"))
	})
	r.GET("/status", func(c *gin.Context) {
		c.Data(http.StatusOK, "", []byte("OK"))
	})
	r.GET("/metrics", notImplemented)

	// Workspaces
	workspaces := r.Group("/workspaces")
	{
		ctrl := factory.NewWorkspaceController()
		workspaces.POST("", ctrl.CreateWorkspace)
		workspaces.GET("", ctrl.ListWorkspaces)
		workspace := workspaces.Group("/:workspace_id")
		{
			workspace.GET("", ctrl.GetWorkspace)
			workspace.PATCH("", ctrl.UpdateWorkspace)
			workspace.DELETE("", ctrl.DeleteWorkspace)
			workspace.GET("/variables", notImplemented)
			workspace.POST("/variables", notImplemented)
			workspace.PATCH("/variables/:variable_id", notImplemented)
			workspace.DELETE("/variables/:variable_id", notImplemented)
			workspace.POST("/lock", notImplemented)
			workspace.POST("/unlock", notImplemented)
		}
	}

	// Plans
	r.GET("/plans/:id", notImplemented)

	// Applies
	r.GET("/applies/:id", notImplemented)

	// Cost Estimates
	r.GET("/estimates/:id", notImplemented)

	// Registry (Modules / Providers)
	registry := r.Group("/registry/:id")
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

	runs := r.Group("/runs")
	{
		runs.POST("", notImplemented)
		runs.GET("/:run_id", notImplemented)
		runs.POST("/:run_id/apply", notImplemented)
		runs.POST("/:run_id/discard", notImplemented)
		runs.POST("/:run_id/cancel", notImplemented)
	}

	webhooks := r.Group("/webhooks")
	{
		provider := webhooks.Group("/:provider")
		{
			provider.POST("/events", notImplemented)
		}
	}

	return r, nil
}

func notImplemented(c *gin.Context) {
	c.AbortWithStatus(501)
}
