package app

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/app"
	"backend-go/middleware"
)

func setupSettingAppRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	settingController := app.NewSettingAppController(db)

	settingGroup := rg.Group("/settings-app")
	{
		settingGroup.GET("/harga-poin", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), settingController.GetHargaPoin)
	}
}
