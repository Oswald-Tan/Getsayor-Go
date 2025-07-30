package web

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/web"
	"backend-go/middleware"
)

func setupShippingRateRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	shippingRateController := web.NewShippingRateController(db)

	shippingGroup := rg.Group("/shipping-rates")
	{
		shippingGroup.GET("", middleware.VerifyUser, middleware.AdminOnly, shippingRateController.GetAllShippingRates)
		shippingGroup.GET("/city/:cityId", middleware.VerifyUser, middleware.AdminOnly, shippingRateController.GetShippingRateByCity)
		shippingGroup.GET("/price/:id", middleware.VerifyUser, middleware.AdminOnly, shippingRateController.GetShippingRateById)
		shippingGroup.POST("", middleware.VerifyUser, middleware.AdminOnly, shippingRateController.CreateShippingRate)
		shippingGroup.PUT("/:id", middleware.VerifyUser, middleware.AdminOnly, shippingRateController.UpdateShippingRate)
		shippingGroup.DELETE("/:id", middleware.VerifyUser, middleware.AdminOnly, shippingRateController.DeleteShippingRate)
	}
}
