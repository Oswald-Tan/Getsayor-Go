package app

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/app"
	"backend-go/middleware"
)

func setupAddressAppRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	addressGroup := rg.Group("/address/app")
	{
		addressController := app.NewAddressController(db)
		addressGroup.POST("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), addressController.CreateAddress)
		addressGroup.GET("/:user_id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), addressController.GetUserAddresses)
		addressGroup.GET("/get-address-id/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), addressController.GetAddressByID)
		addressGroup.PUT("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), addressController.UpdateAddress)
		addressGroup.GET("/default/:user_id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), addressController.GetDefaultAddress)
		addressGroup.DELETE("/:id", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), addressController.DeleteAddress)
	}
}
