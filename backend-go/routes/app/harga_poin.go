package app

import (
	"backend-go/controllers/app"
	"backend-go/middleware"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupHargaPoinRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	hargaPoinGroup := rg.Group("/harga-poin")
	{
		hargaPoinController := app.NewHargaPoinController(db)

		hargaPoinGroup.GET("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), hargaPoinController.GetHargaPoin)
		hargaPoinGroup.GET("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), hargaPoinController.GetHargaPoinById)
		hargaPoinGroup.POST("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), hargaPoinController.CreateHargaPoin)
		hargaPoinGroup.PATCH("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), hargaPoinController.UpdateHargaPoin)
		hargaPoinGroup.DELETE("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), hargaPoinController.DeleteHargaPoin)
	}
}
