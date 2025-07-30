package app

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/controllers/app"
	"backend-go/middleware"
)

func SetupAuthAppRoutes(router *gin.RouterGroup, db *gorm.DB) {
	// Buat grup khusus untuk auth aplikasi dengan prefix auth-app
	authAppGroup := router.Group("/auth-app")
	{
		// Middleware untuk menyetel DB di context (hanya berlaku untuk grup ini)
		authAppGroup.Use(func(c *gin.Context) {
			c.Set("db", db)
			c.Next()
		})

		authAppGroup.POST("/register", app.RegisterUser)

		authAppGroup.POST("/login", app.LoginUser)

		authAppGroup.GET("/user", middleware.AuthMiddleware(), middleware.CheckTokenBlacklist(), app.GetUserData)
		authAppGroup.POST("/logout", middleware.AuthMiddleware(), app.LogoutUser)
		authAppGroup.PUT("/:userId", app.UpdateUser)
		authAppGroup.POST("/request-reset-otp", app.RequestResetOtp)
		authAppGroup.POST("/verify-reset-otp", app.VerifyResetOtp)
		authAppGroup.POST("/reset-password", app.ResetPassword)
		authAppGroup.POST("/get-reset-otp-expiry", app.GetResetOtpExpiry)

		// Endpoint update FCM token (dilindungi auth)
		authAppGroup.PATCH("/update-fcm",
			middleware.AuthMiddleware(),
			middleware.CheckTokenBlacklist(),
			app.UpdateFcmToken,
		)
	}
}
