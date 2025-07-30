package app

import (
	"backend-go/controllers/app"
	"backend-go/middleware"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupCartRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	cartGroup := rg.Group("/cart-app")
	{
		cartController := app.NewCartController(db)

		cartGroup.POST("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), cartController.AddToCart)
		cartGroup.GET("/:userId", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), cartController.GetCartByUser)
		cartGroup.GET("/item-count/:userId", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), cartController.GetItemCountInCart)
		cartGroup.POST("/update-berat", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), cartController.UpdateQuantityInCart)
		cartGroup.DELETE("/:cartId", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), cartController.DeleteCartItem)
	}
}
