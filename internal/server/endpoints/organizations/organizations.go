package organizations

import (
	"github.com/gin-gonic/gin"
	"github.com/robwittman/chushi/internal/models"
	"net/http"
)

type Controller struct {
	Repository models.OrganizationRepository
}

func (ctrl *Controller) Get(c *gin.Context) {
	org, err := ctrl.Repository.FindById(c.Param("organization"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
	} else {
		c.JSON(http.StatusOK, gin.H{
			"organization": org,
		})
	}
}

func (ctrl *Controller) Create(c *gin.Context) {
	var org models.Organization
	if err := c.ShouldBindJSON(&org); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := ctrl.Repository.Save(&org)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
	} else {
		c.JSON(http.StatusOK, gin.H{
			"organization": org,
		})
	}
}

func (ctrl *Controller) List(c *gin.Context) {
	orgs, err := ctrl.Repository.All()
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
	} else {
		c.JSON(http.StatusOK, gin.H{
			"organizations": orgs,
		})
	}
}
