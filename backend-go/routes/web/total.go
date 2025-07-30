package web

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/web"
	"backend-go/middleware"
)

func setupTotalWebRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	totalGroup := rg.Group("/total")
	{
		totalController := web.NewTotalController(db)

		totalGroup.GET("/pesanan-pending", middleware.VerifyUser, middleware.AdminOnly, totalController.GetTotalPesananPending)
		totalGroup.GET("/user-approve-false", middleware.VerifyUser, middleware.AdminOnly, totalController.GetTotalUserApproveFalse)
		totalGroup.GET("/produk", middleware.VerifyUser, middleware.AdminOnly, totalController.GetTotalProduk)
	}
}
