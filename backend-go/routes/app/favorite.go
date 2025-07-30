package app

import (
	"backend-go/controllers/app"
	"backend-go/middleware"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupFavoriteRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	favoriteGroup := rg.Group("/favorites")
	{
		favoriteController := app.NewFavoriteController(db)

		favoriteGroup.GET("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), favoriteController.GetUserFavorites)
		favoriteGroup.GET("/:productId", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), favoriteController.CheckFavorite)
		favoriteGroup.POST("/toggle", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), favoriteController.ToggleFavorite)
	}
}
