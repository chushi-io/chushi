package controller

import (
	"github.com/chushi-io/chushi/internal/resource/registry"
	"github.com/gin-gonic/gin"
)

type RegistryController struct {
	FileStore  registry.Storage
	Repository registry.Repository
}

func (ctrl *RegistryController) List(c *gin.Context) {

}

func (ctrl *RegistryController) Search(c *gin.Context) {

}

func (ctrl *RegistryController) Get(c *gin.Context) {

}

func (ctrl *RegistryController) GetModuleVersions(c *gin.Context) {

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
