package web

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/web"
	"backend-go/middleware"
)

func setupSettingRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	settingController := web.NewSettingController(db)

	settingGroup := rg.Group("/settings")
	{
		settingGroup.GET("/harga-poin", middleware.VerifyUser, middleware.AdminOnly, settingController.GetHargaPoin)
		settingGroup.POST("/harga-poin", middleware.VerifyUser, middleware.AdminOnly, settingController.SetHargaPoin)
	}
}
