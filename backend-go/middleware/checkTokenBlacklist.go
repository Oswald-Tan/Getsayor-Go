package middleware

import (
	"net/http"
	"strings"
	"sync"

	"github.com/gin-gonic/gin"
)

// Gunakan sync.Map untuk thread-safe in-memory storage
var tokenBlacklist sync.Map

// Fungsi untuk menambahkan token ke blacklist
func AddTokenToBlacklist(token string) {
	tokenBlacklist.Store(token, true)
}

// Middleware untuk memeriksa token blacklist
func CheckTokenBlacklist() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"message": "Unauthorized, token required.",
			})
			return
		}

		// Split header untuk mendapatkan token
		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"message": "Invalid authorization format",
			})
			return
		}

		token := parts[1]

		// Periksa apakah token ada di blacklist
		if _, ok := tokenBlacklist.Load(token); ok {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"message": "Token has been invalidated. Please log in again.",
			})
			return
		}

		c.Next()
	}
}
