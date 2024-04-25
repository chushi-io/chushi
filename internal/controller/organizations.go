package controller

import (
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/gin-gonic/gin"
	"net/http"
)

type OrganizationsController struct {
	Repository organization.OrganizationRepository
}

func NewOrganizationsController(repo organization.OrganizationRepository) *OrganizationsController {
	return &OrganizationsController{Repository: repo}
}

func (ctrl *OrganizationsController) SetContext(c *gin.Context) {
	org, err := ctrl.Repository.FindById(c.Param("organization"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
	} else {
		c.Set("organization", org)
	}
}

func (ctrl *OrganizationsController) Entitlements(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"id":         c.Param("organization"),
			"type":       "entitlement-sets",
			"attributes": gin.H{"operations": true},
		},
	})
}

func (ctrl *OrganizationsController) Get(c *gin.Context) {
	org, err := ctrl.Repository.FindById(c.Param("organization"))
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
	} else {
		c.JSON(http.StatusOK, gin.H{
			"organization": org,
		})
	}
}

func (ctrl *OrganizationsController) Create(c *gin.Context) {
	var org organization.Organization
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

func (ctrl *OrganizationsController) List(c *gin.Context) {
	orgs, err := ctrl.Repository.All()
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
	} else {
		c.JSON(http.StatusOK, gin.H{
			"organizations": orgs,
		})
	}
}
