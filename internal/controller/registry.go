package controller

import (
	"github.com/chushi-io/chushi/internal/resource/registry"
	"github.com/gin-gonic/gin"
	"net/http"
)

type RegistryController struct {
	FileStore  registry.Storage
	Repository registry.Repository
}

func (ctrl *RegistryController) VerifyOwnership(c *gin.Context) {
	//module, err := ctrl.Repository
}

func (ctrl *RegistryController) List(c *gin.Context) {

}

func (ctrl *RegistryController) Search(c *gin.Context) {

}

func (ctrl *RegistryController) Get(c *gin.Context) {

}

func (ctrl *RegistryController) GetModuleVersions(c *gin.Context) {
	// Get the module
	c.JSON(http.StatusOK, gin.H{
		"modules": []map[string]interface{}{
			{
				"source": "chushi/demo/aws",
				"versions": []map[string]interface{}{
					{
						"version": "1.0.0",
						"root": map[string]interface{}{
							"providers": []map[string]interface{}{
								{
									"name":      "aws",
									"namespace": "chushi",
									"source":    "hashicorp/aws",
									"version":   ">= 5.20",
								},
							},
						},
					},
				},
			},
		},
	})
}

func (ctrl *RegistryController) GetModuleVersion(c *gin.Context) {

}

func (ctrl *RegistryController) DownloadModuleVersion(c *gin.Context) {

}

func (ctrl *RegistryController) Create(c *gin.Context) {

}

func (ctrl *RegistryController) CreateModuleVersion(c *gin.Context) {

}

func (ctrl *RegistryController) Update(c *gin.Context) {

}

func (ctrl *RegistryController) UpdateModuleVersion(c *gin.Context) {

}

func (ctrl *RegistryController) Delete(c *gin.Context) {

}

func (ctrl *RegistryController) DeleteModuleVersion(c *gin.Context) {

}
