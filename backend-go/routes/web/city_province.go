package web

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/web"
	"backend-go/middleware"
)

func setupProvinceCityRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	provinceGroup := rg.Group("/provinces")
	{
		cpController := web.NewCityProvinceController(db)
		// HAPUS SLASH DI AKHIR PATH
		provinceGroup.GET("", middleware.VerifyUser, middleware.AdminOnly, cpController.GetProvinceAndCity)
		provinceGroup.GET("/cities", middleware.VerifyUser, middleware.AdminOnly, cpController.GetCity)
		provinceGroup.POST("", middleware.VerifyUser, middleware.AdminOnly, cpController.CreateProvinceAndCity)
		provinceGroup.DELETE("/:id", middleware.VerifyUser, middleware.AdminOnly, cpController.DeleteProvinceAndCities)
	}
}
