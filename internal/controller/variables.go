package controller

import (
	"github.com/chushi-io/chushi/internal/helpers"
	"github.com/chushi-io/chushi/internal/resource/variables"
	"github.com/gin-gonic/gin"
	"net/http"
)

type VariablesController struct {
	Repository variables.Repository
}

func (ctrl *VariablesController) List(c *gin.Context) {

}

func (ctrl *VariablesController) Get(c *gin.Context) {

}

type CreateVariableInput struct {
	Name        string `json:"name"`
	Value       string `json:"value"`
	Description string `json:"description"`
	Type        string `json:"type"`
	Sensitive   bool   `json:"sensitive"`
	Hcl         bool   `json:"hcl"`
}

func (ctrl *VariablesController) Create(c *gin.Context) {
	org := helpers.GetOrganization(c)
	var input CreateVariableInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.AbortWithError(http.StatusBadRequest, err)
		return
	}

	variable := &variables.Variable{
		Name:           input.Name,
		Description:    input.Description,
		Type:           variables.ToVariableType(input.Type),
		Sensitive:      input.Sensitive,
		OrganizationID: org.ID,
		Value:          input.Value,

		// Hcl: input.Hcl
	}
	if variableSetId := c.Param("variable_set"); variableSetId != "" {
		vsid, _ := helpers.GetUuid(variableSetId)
		variable.VariableSetID = vsid
	}

	if _, err := ctrl.Repository.Create(variable); err != nil {
		c.AbortWithError(http.StatusInternalServerError, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"variable": variable,
	})
}

func (ctrl *VariablesController) Update(c *gin.Context) {

}

func (ctrl *VariablesController) Delete(c *gin.Context) {

}
