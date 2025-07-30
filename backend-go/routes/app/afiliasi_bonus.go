package app

import (
	"backend-go/controllers/app"
	"backend-go/middleware"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupAfiliasiRoutes(rg *gin.RouterGroup, db *gorm.DB) {

	afiliasiGroup := rg.Group("/afiliasi-app")
	{
		afiliasiController := app.NewAfiliasiBonusController(db)
		afiliasiGroup.POST("/claim", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), afiliasiController.ClaimBonus)
		afiliasiGroup.GET("/total/:userId", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), afiliasiController.GetTotalBonus)
		afiliasiGroup.GET("/pending/:userId", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), afiliasiController.GetPendingBonus)
		afiliasiGroup.GET("/expired/:userId", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), afiliasiController.GetExpiredBonus)
	}
}
