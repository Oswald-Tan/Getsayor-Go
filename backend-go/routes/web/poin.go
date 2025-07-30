package web

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/web"
	"backend-go/middleware"
)

func setupPoinRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	poinController := web.NewPoinController(db)

	poinGroup := rg.Group("/poins")
	{
		poinGroup.GET("", middleware.VerifyUser, middleware.AdminOnly, poinController.GetPoins)
		poinGroup.GET("/:id", middleware.VerifyUser, middleware.AdminOnly, poinController.GetPoinById)
		poinGroup.POST("", middleware.VerifyUser, middleware.AdminOnly, poinController.CreatePoin)
		poinGroup.POST("/update-discount", middleware.VerifyUser, middleware.AdminOnly, poinController.UpdateDiscount)
		poinGroup.PATCH("/:id", middleware.VerifyUser, middleware.AdminOnly, poinController.UpdatePoin)
		poinGroup.DELETE("/:id", middleware.VerifyUser, middleware.AdminOnly, poinController.DeletePoin)
	}
}
