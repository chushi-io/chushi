package controller

import (
	"context"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/gin-gonic/gin"
	"github.com/volatiletech/authboss/v3"
	"gorm.io/gorm"
	"net/http"
)

type MeController struct {
	Database *gorm.DB
	Auth     *authboss.Authboss
}

func (ctrl *MeController) ListOrganizations(c *gin.Context) {
	currentUser, err := ctrl.Auth.CurrentUser(c.Request)
	if err != nil {
		c.AbortWithStatus(http.StatusUnauthorized)
		return
	}

	user, err := ctrl.Auth.Storage.Server.Load(context.TODO(), currentUser.GetPID())
	if err != nil {
		c.AbortWithStatus(http.StatusUnauthorized)
		return
	}

	var orgs []organization.Organization
	err = ctrl.Database.Model(user.(*organization.User)).Association("Organizations").Find(&orgs)
	if err != nil {
		c.AbortWithStatus(http.StatusInternalServerError)
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"organizations": orgs,
	})
}
