package middleware

import (
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		tokenString := ""

		// Ekstrak token dari header
		if authHeader != "" {
			parts := strings.Split(authHeader, " ")
			if len(parts) == 2 && parts[0] == "Bearer" {
				tokenString = parts[1]
			}
		}

		if tokenString == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"message": "Unauthorized, token required",
			})
			return
		}

		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}
			return []byte(os.Getenv("TOKEN_JWT")), nil
		})

		if err != nil {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"message": "Token invalid or expired",
				"error":   err.Error(),
			})
			return
		}

		if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
			// Pastikan claim ID ada dan konversi ke uint
			if id, exists := claims["id"]; exists {
				var userID uint
				switch v := id.(type) {
				case float64:
					userID = uint(v)
				case int:
					userID = uint(v)
				case uint:
					userID = v
				default:
					c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
						"message": "Invalid user ID format in token",
					})
					return
				}

				// Simpan userID di context
				c.Set("userID", userID)
				c.Next()
				return
			}
		}

		c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
			"message": "Invalid token claims",
		})
	}
}
