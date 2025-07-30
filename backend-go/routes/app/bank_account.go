package app

import (
	"backend-go/controllers/app"
	"backend-go/middleware"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupBankAccountRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	bankAccountGroup := rg.Group("/bank-accounts")
	{
		bankAccountController := app.NewBankAccountController(db)

		bankAccountGroup.POST("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), bankAccountController.CreateOrUpdateBankAccount)
		bankAccountGroup.GET("/:userId", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), bankAccountController.GetBankAccountByUserId)
		bankAccountGroup.DELETE("/:userId", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), bankAccountController.DeleteBankAccount)
	}
}
