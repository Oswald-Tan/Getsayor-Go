package app

import (
	"backend-go/controllers/app"
	"backend-go/middleware"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupPesananAppRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	orderGroup := rg.Group("/pesanan-app")
	{
		orderController := app.NewOrderController(db)

		orderGroup.GET("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), orderController.GetPesanan)
		orderGroup.GET("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), orderController.GetPesananByID)
		orderGroup.GET("/user/:userId", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), orderController.GetPesananByUser)
		orderGroup.GET("/user-delivered/:userId", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), orderController.GetPesananByUserDelivered)
		orderGroup.GET("/check", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), orderController.CheckOrder)
		orderGroup.POST("/cod", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), orderController.BuatPesananCOD)
		orderGroup.POST("/cod-cart", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), orderController.BuatPesananCODCart)
		orderGroup.POST("/poin", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), orderController.BuatPesananPoin)
		orderGroup.POST("/poin-cart", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), orderController.BuatPesananPoinCart)
		orderGroup.DELETE("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), orderController.DeletePesanan)
	}
}
