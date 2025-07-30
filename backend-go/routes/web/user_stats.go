package web

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/web"
	"backend-go/middleware"
)

func setupUserStatsRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	userGroup := rg.Group("/user-stats")
	{
		// User stats routes
		userStatsController := web.NewUserStatsController(db)
		userGroup.GET("/:id/stats", middleware.VerifyUser, middleware.AdminOnly, userStatsController.GetUserStats)

	}
}
