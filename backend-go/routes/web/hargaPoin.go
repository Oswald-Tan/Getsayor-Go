package web

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/web"
	"backend-go/middleware"
)

func SetupHargaPoinRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	hargaPoinController := web.NewHargaPoinController(db)

	hargaPoinGroup := rg.Group("/harga-poin")
	hargaPoinGroup.Use(middleware.VerifyUser, middleware.AdminOnly)
	{
		hargaPoinGroup.GET("", hargaPoinController.GetHargaPoin)
		hargaPoinGroup.GET("/:id", hargaPoinController.GetHargaPoinById)
		hargaPoinGroup.POST("", hargaPoinController.CreateHargaPoin)
		hargaPoinGroup.PATCH("/:id", hargaPoinController.UpdateHargaPoin)
		hargaPoinGroup.DELETE("/:id", hargaPoinController.DeleteHargaPoin)
	}
}
