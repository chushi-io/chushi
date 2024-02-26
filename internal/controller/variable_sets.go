package controller

import (
	"github.com/chushi-io/chushi/internal/helpers"
	"github.com/chushi-io/chushi/internal/resource/variables"
	"github.com/gin-gonic/gin"
	"net/http"
)

type VariableSetsController struct {
	Repository variables.SetRepository
}

func (ctrl *VariableSetsController) List(c *gin.Context) {
	org := helpers.GetOrganization(c)
	variableSets, err := ctrl.Repository.List(&variables.ListVariableSetParams{
		OrganizationId: &org.ID,
		WorkspaceId:    nil,
	})
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"variable_sets": variableSets,
	})
}

func (ctrl *VariableSetsController) Get(c *gin.Context) {
	//org := helpers.GetOrganization(c)
	variableSetId, _ := helpers.GetUuid(c.Param("variable_set"))

	variableSet, err := ctrl.Repository.Get(variableSetId)
	if err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"variable_set": variableSet,
	})
}

type CreateVariableSetInput struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	AutoAttach  bool   `json:"auto_attach"`
	Priority    int32  `json:"priority"`
}

func (ctrl *VariableSetsController) Create(c *gin.Context) {
	org := helpers.GetOrganization(c)
	var input CreateVariableSetInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	variableSet := &variables.VariableSet{
		Name:           input.Name,
		Description:    input.Description,
		AutoAttach:     input.AutoAttach,
		Priority:       input.Priority,
		OrganizationID: org.ID,
	}
	if _, err := ctrl.Repository.Create(variableSet); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"variable_set": variableSet,
	})
}

func (ctrl *VariableSetsController) Update(c *gin.Context) {

}

func (ctrl *VariableSetsController) Delete(c *gin.Context) {

}
