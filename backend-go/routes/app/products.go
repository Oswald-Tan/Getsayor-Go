package app

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/app"
	"backend-go/middleware"
)

func setupProductAppRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	productController := app.NewProductController(db)

	productGroup := rg.Group("/products/app")
	{
		// Admin routes
		productGroup.GET("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), productController.GetProducts)
		productGroup.GET("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), productController.GetProductById)
		productGroup.DELETE("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), productController.DeleteProduct)

		// App routes (no admin check, but require authentication)
		productGroup.GET("/app", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), productController.GetProductsApp)
		productGroup.GET("/search", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), productController.SearchProductsApp)
	}
}
