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

		orderGroup.GET("", middleware.VerifyUser, orderController.GetPesanan)
		orderGroup.GET("/:id", middleware.VerifyUser, orderController.GetPesananByID)
		orderGroup.GET("/status/:id", middleware.VerifyUser, orderController.GetPesananStatusByID)
		orderGroup.PUT("/:id", middleware.VerifyUser, orderController.UpdatePesananStatus)
		orderGroup.DELETE("/:id", middleware.VerifyUser, orderController.DeletePesanan)
	}
}
