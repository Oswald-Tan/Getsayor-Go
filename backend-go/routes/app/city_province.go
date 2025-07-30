package app

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/app"
	"backend-go/middleware"
)

func setupProvinceCityAppRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	provinceGroup := rg.Group("/provinces-cities")
	{
		cpController := app.NewCityProvinceController(db)
		// HAPUS SLASH DI AKHIR PATH
		provinceGroup.GET("", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), cpController.GetProvinceAndCity)
		provinceGroup.GET("/cities", middleware.VerifyUser, middleware.AdminOnly, cpController.GetCity)
		provinceGroup.POST("", middleware.VerifyUser, middleware.AdminOnly, cpController.CreateProvinceAndCity)
		provinceGroup.DELETE("/:id", middleware.VerifyUser, middleware.AdminOnly, cpController.DeleteProvinceAndCities)
	}
}
