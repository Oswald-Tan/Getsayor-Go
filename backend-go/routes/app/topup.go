package app

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/app"
	"backend-go/middleware"
)

func setupTopUpAppRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	topUpGroup := rg.Group("/topup-app")
	{
		topUpController := app.NewTopUpPoinController(db)
		topUpGroup.POST("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), topUpController.PostTopUp)
		topUpGroup.GET("/user", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), topUpController.GetTopUpByUserId)
		topUpGroup.GET("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), topUpController.GetTopUp)
		topUpGroup.GET("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), topUpController.GetTopUpById)
	}
}
