package controller

import (
	"errors"
	"github.com/chushi-io/chushi/internal/resource/access_token"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/gin-gonic/gin"
	"net/http"
	"time"
)

type AccessTokensController struct {
	Repository access_token.Repository
}

func NewAccessTokensController(repo access_token.Repository) *AccessTokensController {
	return &AccessTokensController{Repository: repo}
}

func (ctrl *AccessTokensController) List(c *gin.Context) {
	userCtx, _ := c.Get("user")
	userInfo, ok := userCtx.(*organization.User)
	if !ok {
		c.AbortWithError(http.StatusUnauthorized, errors.New("unable to load user"))
		return
	}

	accessTokens, err := ctrl.Repository.List(userInfo.ID)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"access_tokens": accessTokens})
}

type CreateTokenPayload struct {
	Name      string     `json:"name"`
	ExpiresAt *time.Time `json:"expires_at,omitempty"`
}

func (ctrl *AccessTokensController) Create(c *gin.Context) {
	userCtx, _ := c.Get("user")
	userInfo, ok := userCtx.(*organization.User)
	if !ok {
		c.AbortWithError(http.StatusUnauthorized, errors.New("unable to load user"))
		return
	}

	var request CreateTokenPayload
	if err := c.BindJSON(&request); err != nil {
		c.AbortWithError(http.StatusBadRequest, errors.New("name not provided"))
		return
	}

	accessToken := &access_token.AccessToken{
		UserId:    userInfo.ID,
		Name:      request.Name,
		ExpiresAt: request.ExpiresAt,
	}

	_, err := ctrl.Repository.Create(accessToken)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"access_token": gin.H{
		"id":    accessToken.Id,
		"token": accessToken.Token,
	}})
}
