package web

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/web"
	"backend-go/middleware"
)

func setupUserRoutes(rg *gin.RouterGroup, db *gorm.DB) {
	userController := web.NewUserController(db)

	userGroup := rg.Group("/users")
	{
		userGroup.GET("", middleware.VerifyUser, middleware.AdminOnly, userController.GetUsers)
		userGroup.GET("/deleted", middleware.VerifyUser, middleware.AdminOnly, userController.GetDeletedUsers)
		userGroup.GET("/approve", middleware.VerifyUser, middleware.AdminOnly, userController.GetUserApprove)
		userGroup.GET("/:id/details", middleware.VerifyUser, middleware.AdminOnly, userController.GetUserDetails)
		userGroup.GET("/:id/points", middleware.VerifyUser, middleware.AdminOnly, userController.GetUserPoints)
		userGroup.GET("/:id", middleware.VerifyUser, middleware.AdminOnly, userController.GetUserById)
		userGroup.GET("/total", middleware.VerifyUser, userController.GetTotalUsers)
		userGroup.PUT("/approve", middleware.VerifyUser, middleware.AdminOnly, userController.ApproveUser)
		userGroup.PUT("/approve-users", middleware.VerifyUser, middleware.AdminOnly, userController.ApproveUsers)
		userGroup.PUT("/:userId/points", middleware.VerifyUser, middleware.AdminOnly, userController.UpdateUserPoints)
		userGroup.PUT("/restore/:id", middleware.VerifyUser, middleware.AdminOnly, userController.RestoreUser)
		userGroup.POST("", middleware.VerifyUser, middleware.AdminOnly, userController.CreateUser)
		userGroup.POST("/restore-user", middleware.VerifyUser, middleware.AdminOnly, userController.RestoreUser)
		userGroup.PATCH("/:id", middleware.VerifyUser, middleware.AdminOnly, userController.UpdateUser)
		userGroup.DELETE("/:id", middleware.VerifyUser, middleware.AdminOnly, userController.SoftDeleteUser)
		userGroup.DELETE("/permanent/:id", middleware.VerifyUser, middleware.AdminOnly, userController.PermanentDeleteUser)
	}
}
