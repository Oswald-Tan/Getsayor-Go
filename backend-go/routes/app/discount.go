package app

import (
	"backend-go/controllers/app"
	"backend-go/middleware"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupDiscountRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	discountGroup := rg.Group("/discounts")
	{
		discountController := app.NewDiscountController(db)

		discountGroup.GET("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), discountController.GetDiscountPoin)
		discountGroup.GET("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), discountController.GetDiscountPoinById)
		discountGroup.POST("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), discountController.CreateDiscountPoin)
		discountGroup.PATCH("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), discountController.UpdateDiscountPoin)
		discountGroup.DELETE("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), discountController.DeleteDiscountPoin)
	}
}
