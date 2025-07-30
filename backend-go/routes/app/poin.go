package app

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/app"
	"backend-go/middleware"
)

func setupPoinAppRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	poinController := app.NewPoinController(db)

	poinGroup := rg.Group("/poin-app")
	{
		poinGroup.GET("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), poinController.GetPoins)
		poinGroup.GET("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), poinController.GetPoinById)
		poinGroup.POST("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), poinController.CreatePoin)
		poinGroup.POST("/update-discount", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), poinController.UpdateDiscount)
		poinGroup.PATCH("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), poinController.UpdatePoin)
		poinGroup.DELETE("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), poinController.DeletePoin)
	}
}
