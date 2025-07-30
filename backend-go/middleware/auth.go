package middleware

import (
	"net/http"

	"github.com/gin-contrib/sessions"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

func VerifyUser(c *gin.Context) {
	session := sessions.Default(c)
	userID := session.Get("userId")

	if userID == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Mohon login ke akun Anda!"})
		c.Abort()
		return
	}

	var user models.User
	db := c.MustGet("db").(*gorm.DB)

	if err := db.Preload("Role").First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		c.Abort()
		return
	}

	c.Set("userId", user.ID)
	c.Set("role", user.Role.RoleName)
	c.Next()
}

func AdminOnly(c *gin.Context) {
	session := sessions.Default(c)
	role := session.Get("role")

	if role == nil || role.(string) != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"message": "Admin access required"})
		c.Abort()
		return
	}
	c.Next()
}
