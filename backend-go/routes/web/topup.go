package web

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/web"
	"backend-go/middleware"
)

func setupTopUpWebRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	topUpGroup := rg.Group("/topup-web")
	{
		topUpController := web.NewTopUpPoinController(db)

		topUpGroup.GET("", middleware.VerifyUser, middleware.AdminOnly, topUpController.GetTopUp)
		topUpGroup.GET("/approved", middleware.VerifyUser, middleware.AdminOnly, topUpController.GetTotalApprovedTopUp)
		topUpGroup.GET("/:id", middleware.VerifyUser, middleware.AdminOnly, topUpController.GetTopUpById)
		topUpGroup.GET("/total/:period", middleware.VerifyUser, middleware.AdminOnly, topUpController.GetTotalTopUp)
		topUpGroup.PATCH("/:id", middleware.VerifyUser, middleware.AdminOnly, topUpController.UpdateTopUp)
		topUpGroup.DELETE("/:id", middleware.VerifyUser, middleware.AdminOnly, topUpController.DeleteTopUp)
	}
}
