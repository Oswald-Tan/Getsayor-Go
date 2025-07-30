package web

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/web"
	"backend-go/middleware"
)

func setupAuthRoutes(rg *gin.RouterGroup, _ *gorm.DB) {
	authGroup := rg.Group("/auth-web")
	{
		authGroup.POST("/handle-login", web.HandleLogin)
		authGroup.GET("/me", web.Me)
		authGroup.PUT("/update-pass/:id", middleware.VerifyUser, web.UpdatePassword)
		authGroup.DELETE("/handle-logout", web.HandleLogout)
		authGroup.POST("/request-reset-otp", web.RequestResetOtp)
		authGroup.POST("/verify-reset-otp", web.VerifyResetOtp)
		authGroup.POST("/reset-password", web.ResetPassword)
		authGroup.POST("/get-reset-otp-expiry", web.GetResetOtpExpiry)
	}
}
