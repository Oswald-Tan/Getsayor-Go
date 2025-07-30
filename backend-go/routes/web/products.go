package web

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/web"
	"backend-go/middleware"
)

func setupProductRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	productController := web.NewProductController(db)

	productGroup := rg.Group("/products")
	{
		// Admin routes
		productGroup.GET("", middleware.VerifyUser, middleware.AdminOnly, productController.GetProducts)
		productGroup.GET("/:id", middleware.VerifyUser, middleware.AdminOnly, productController.GetProductById)
		productGroup.POST("", middleware.VerifyUser, middleware.AdminOnly, middleware.UploadFile("image"), productController.CreateProduct)
		productGroup.PATCH("/:id", middleware.VerifyUser, middleware.AdminOnly, middleware.UploadFile("image"), productController.UpdateProduct)
		productGroup.DELETE("/:id", middleware.VerifyUser, middleware.AdminOnly, productController.DeleteProduct)
	}
}
