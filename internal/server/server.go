package server

import (
	"github.com/gin-gonic/gin"
	"github.com/robwittman/chushi/internal/server/config"
	"net/http"
)

func New(conf *config.Config) (*gin.Engine, error) {
	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})
	return r, nil
}
