package web

import (
	"backend-go/controllers/web"
	"backend-go/middleware"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupPesananRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	orderGroup := rg.Group("/pesanan")
	{
		orderController := web.NewOrderController(db)

		orderGroup.GET("", middleware.VerifyUser, middleware.AdminOnly, orderController.GetPesanan)
		orderGroup.GET("/:id", middleware.VerifyUser, middleware.AdminOnly, orderController.GetPesananByID)
		orderGroup.PUT("/:id", middleware.VerifyUser, middleware.AdminOnly, orderController.UpdatePesananStatus)
		orderGroup.DELETE("/:id", middleware.VerifyUser, middleware.AdminOnly, orderController.DeletePesanan)
	}
}
