package controller

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

type AuthController struct {
}

func (ctrl *AuthController) Login(c *gin.Context) {
	if c.Request.Method == http.MethodGet {
		// Render login page
		return
	}

	// Process the user login
	return
}

func (ctrl *AuthController) Register(c *gin.Context) {
	if c.Request.Method == http.MethodGet {
		// Render registration page
		return
	}

	// Process user registration
	return
}
