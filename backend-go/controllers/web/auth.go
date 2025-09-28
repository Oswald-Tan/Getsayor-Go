package web

import (
	"crypto/rand"
	"errors"
	"fmt"
	"math/big"
	"net/http"
	"os"
	"time"

	"github.com/gin-contrib/sessions"
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"

	"backend-go/config"
	"backend-go/models"
)

type LoginRequest struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

func HandleLogin(c *gin.Context) {
	var req struct {
		Email    string `json:"email" binding:"required,email"`
		Password string `json:"password" binding:"required,min=8"`
	}

	// Validasi input
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "Invalid request",
			"error":   err.Error(),
		})
		return
	}

	db := c.MustGet("db").(*gorm.DB)
	var user models.User

	// Cari user dengan eager loading Role dan Details
	if err := db.Preload("Role").Preload("Details").
		Where("email = ?", req.Email).
		First(&user).Error; err != nil {

		if errors.Is(err, gorm.ErrRecordNotFound) {
			// Email tidak ditemukan
			c.JSON(http.StatusUnauthorized, gin.H{
				"message": "Email not found",
				"error":   "No account associated with this email",
			})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{
				"message": "Database error",
				"error":   err.Error(),
			})
		}
		return
	}

	// Verifikasi password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		// Password salah
		c.JSON(http.StatusUnauthorized, gin.H{
			"message": "Invalid password",
			"error":   "Incorrect password for this account",
		})
		return
	}

	// Validasi role
	if user.Role == nil {
		c.JSON(http.StatusForbidden, gin.H{"message": "User role not found"})
		return
	}

	if user.Role.RoleName != "admin" && user.Role.RoleName != "kurir" {
		c.JSON(http.StatusForbidden, gin.H{
			"message": "Access denied",
			"error":   "Only admin and courier roles are allowed to login",
		})
		return
	}

	// Set session
	session := sessions.Default(c)
	session.Set("userId", user.ID)
	session.Set("role", user.Role.RoleName) // Simpan role di session

	if err := session.Save(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "Failed to save session",
			"error":   err.Error(),
		})
		return
	}

	// Response
	response := gin.H{
		"id":    user.ID,
		"email": user.Email,
		"role":  user.Role.RoleName,
	}

	// Tambahkan fullname jika ada
	if user.Details != nil && user.Details.Fullname != "" {
		response["fullname"] = user.Details.Fullname
	} else {
		response["fullname"] = "-"
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Login successful",
		"data":    response,
	})
}

func Me(c *gin.Context) {
	session := sessions.Default(c)
	userID := session.Get("userId")
	if userID == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Mohon login ke akun Anda!"})
		return
	}

	db := c.MustGet("db").(*gorm.DB)
	var user models.User
	if err := db.Preload("Role").Preload("Details").
		Where("id = ?", userID).
		First(&user).Error; err != nil {

		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Database error"})
		}
		return
	}

	// Handle nullable fields
	fullname := "-"
	if user.Details != nil {
		fullname = user.Details.Fullname
	}

	roleName := "-"
	if user.Role != nil {
		roleName = user.Role.RoleName
	}

	c.JSON(http.StatusOK, gin.H{
		"id":       user.ID,
		"fullname": fullname, // Gunakan nilai default jika nil
		"email":    user.Email,
		"role":     roleName, // Gunakan nilai default jika nil
	})
}

func UpdatePassword(c *gin.Context) {
	userID := c.MustGet("userId").(uint) // Dari middleware VerifyUser
	targetID := c.Param("id")

	// Pastikan user hanya mengupdate password sendiri
	if fmt.Sprint(userID) != targetID {
		c.JSON(http.StatusForbidden, gin.H{"message": "You can only update your own password"})
		return
	}

	db := c.MustGet("db").(*gorm.DB)
	var user models.User
	if err := db.First(&user, targetID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		return
	}

	// Buat password baru: email + "123"
	newPassword := user.Email + "123"
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to generate password"})
		return
	}

	// Update password
	if err := db.Model(&user).Update("password", string(hashedPassword)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update password"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Password berhasil diubah.",
		"success": true,
	})
}

func HandleLogout(c *gin.Context) {
	session := sessions.Default(c)

	// Hapus semua nilai session
	session.Clear()

	// Tentukan domain berdasarkan environment
	domain := "localhost" // default untuk development
	if os.Getenv("ENV") == "production" {
		domain = ".getsayor.com" // format domain utama untuk production
	}

	// Set opsi untuk menghapus cookie
	session.Options(sessions.Options{
		Path:     "/",
		Domain:   domain, // Harus sama dengan saat login
		MaxAge:   -1,     // Instruksikan browser untuk menghapus cookie
		HttpOnly: true,
		Secure:   os.Getenv("ENV") == "production",
		SameSite: http.SameSiteLaxMode,
	})

	// Simpan perubahan untuk mengirimkan Set-Cookie header
	if err := session.Save(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Logout failed"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Logout success"})
}

// RequestResetOtp generates and sends OTP to the user's email
func RequestResetOtp(c *gin.Context) {
	type Request struct {
		Email string `json:"email" binding:"required"`
	}

	var req Request
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request"})
		return
	}

	db := c.MustGet("db").(*gorm.DB)
	var user models.User
	result := db.Where("email = ?", req.Email).First(&user)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		return
	}

	// Generate 6-digit OTP
	otp, err := generateOTP(6)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to generate OTP"})
		return
	}

	// Set expiration time (10 minutes from now)
	expiryTime := time.Now().Add(10 * time.Minute)

	// Save OTP and expiry time to user
	// Gunakan pointer ke otp
	user.ResetOtp = &otp
	user.ResetOtpExpires = &expiryTime
	if err := db.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to save OTP"})
		return
	}

	// Send OTP via email
	mailer := config.NewMailer()
	subject := "Your OTP Code for Password Reset"
	body := fmt.Sprintf(`
		<!DOCTYPE html>
		<html>
		<head>
			<style>
				body {
					font-family: Arial, sans-serif;
					background-color: #f4f4f4;
					color: #333;
					margin: 0;
					padding: 0;
				}
				.container {
					max-width: 600px;
					margin: 20px auto;
					background: #fff;
					padding: 20px;
					border-radius: 8px;
					box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
				}
				h1 {
					color: #007BFF;
					text-align: center;
				}
				p {
					font-size: 16px;
					text-align: center;
				}
				.otp {
					font-size: 24px;
					font-weight: bold;
					color: #007BFF;
					text-align: center;
				}
			</style>
		</head>
		<body>
			<div class="container">
				<h1>Password Reset OTP</h1>
				<p>Your OTP code is:</p>
				<p class="otp">%s</p>
				<p>This code will expire in 10 minutes.</p>
				<p>If you did not request this, please ignore this email.</p>
			</div>
		</body>
		</html>
	`, otp)

	if err := mailer.SendEmail(user.Email, subject, body); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to send OTP email"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "OTP has been sent to your email"})
}

// VerifyResetOtp verifies the OTP entered by the user
func VerifyResetOtp(c *gin.Context) {
	type RequestBody struct {
		Email string `json:"email"`
		Otp   string `json:"otp"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	db := c.MustGet("db").(*gorm.DB)

	var user models.User
	if err := db.Where("email = ?", reqBody.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		return
	}

	// Validasi OTP
	if user.ResetOtp == nil || *user.ResetOtp != reqBody.Otp {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid OTP"})
		return
	}

	// Validasi waktu kadaluarsa
	if user.ResetOtpExpires == nil || time.Now().After(*user.ResetOtpExpires) {
		c.JSON(http.StatusBadRequest, gin.H{"message": "OTP has expired"})
		return
	}

	// Reset OTP fields
	user.ResetOtp = nil
	user.ResetOtpExpires = nil

	if err := db.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to reset OTP"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "OTP verified successfully"})
}

// ResetPassword resets the user's password after OTP verification
func ResetPassword(c *gin.Context) {
	type Request struct {
		Email           string `json:"email" binding:"required"`
		NewPassword     string `json:"newPassword" binding:"required"`
		ConfirmPassword string `json:"confirmPassword" binding:"required"`
	}

	var req Request
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request"})
		return
	}

	// Check if passwords match
	if req.NewPassword != req.ConfirmPassword {
		c.JSON(http.StatusBadRequest, gin.H{"message": "New password and confirm password do not match"})
		return
	}

	// Validate password strength
	if !validatePassword(req.NewPassword) {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "Password must be at least 8 characters long and include letters, numbers, and special characters",
		})
		return
	}

	db := c.MustGet("db").(*gorm.DB)
	var user models.User
	result := db.Where("email = ?", req.Email).First(&user)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		return
	}

	// Hash the new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to hash password"})
		return
	}

	// Update password and clear OTP fields
	user.Password = string(hashedPassword)
	user.ResetOtp = nil // Set ke nil, bukan string kosong
	user.ResetOtpExpires = nil
	if err := db.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update password"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Password reset successfully"})
}

// GetResetOtpExpiry returns the expiry time of the OTP for the user
func GetResetOtpExpiry(c *gin.Context) {
	type Request struct {
		Email string `json:"email" binding:"required"`
	}

	var req Request
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request"})
		return
	}

	db := c.MustGet("db").(*gorm.DB)
	var user models.User
	result := db.Where("email = ?", req.Email).First(&user)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		return
	}

	if user.ResetOtpExpires == nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "OTP not requested"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"expiryTime": user.ResetOtpExpires})
}

// Helper function to generate OTP
func generateOTP(length int) (string, error) {
	const charset = "0123456789"
	result := make([]byte, length)
	for i := range result {
		num, err := rand.Int(rand.Reader, big.NewInt(int64(len(charset))))
		if err != nil {
			return "", err
		}
		result[i] = charset[num.Int64()]
	}
	return string(result), nil
}

// Helper function to validate password
func validatePassword(password string) bool {
	if len(password) < 8 {
		return false
	}
	hasLetter := false
	hasNumber := false
	hasSpecial := false
	for _, ch := range password {
		switch {
		case 'a' <= ch && ch <= 'z' || 'A' <= ch && ch <= 'Z':
			hasLetter = true
		case '0' <= ch && ch <= '9':
			hasNumber = true
		case ch == '!' || ch == '@' || ch == '#' || ch == '$' || ch == '%' || ch == '^' || ch == '&' || ch == '*' || ch == '(' || ch == ')' || ch == ',' || ch == '.' || ch == '?' || ch == ':' || ch == '"' || ch == '{' || ch == '}' || ch == '|' || ch == '<' || ch == '>':
			hasSpecial = true
		}
	}
	return hasLetter && hasNumber && hasSpecial
}
