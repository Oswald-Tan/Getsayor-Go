package app

import (
	"backend-go/middleware"
	"backend-go/models"
	"crypto/rand"
	"math/big"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// Register User
func RegisterUser(c *gin.Context) {
	type RequestBody struct {
		Fullname     string `json:"fullname"`
		Password     string `json:"password"`
		Email        string `json:"email"`
		RoleName     string `json:"role_name"`
		ReferralCode string `json:"referralCode"`
		PhoneNumber  string `json:"phone_number"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	if reqBody.Fullname == "" || reqBody.Password == "" || reqBody.Email == "" ||
		reqBody.PhoneNumber == "" || reqBody.RoleName == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "Fullname, password, email, phone_number, and role are required.",
		})
		return
	}

	db := c.MustGet("db").(*gorm.DB)

	// Check existing email
	var existingUser models.User
	if err := db.Where("email = ?", reqBody.Email).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Email already registered."})
		return
	}

	// Check existing phone number
	var existingDetails models.DetailsUser
	if err := db.Where("phone_number = ?", reqBody.PhoneNumber).First(&existingDetails).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Phone number already registered."})
		return
	}

	// Find or create role
	var role models.Role
	if err := db.Where("role_name = ?", reqBody.RoleName).First(&role).Error; err != nil {
		role = models.Role{RoleName: "user"}
		if err := db.Create(&role).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create role"})
			return
		}
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(reqBody.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to hash password"})
		return
	}

	// Generate referral code
	referralCode, err := generateUniqueReferralCode(db)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to generate referral code"})
		return
	}

	// Handle referral
	var referredBy *uint
	var referralUsedAt *time.Time
	if reqBody.ReferralCode != "" {
		var referrer models.User
		if err := db.Where("referral_code = ?", reqBody.ReferralCode).First(&referrer).Error; err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid referral code."})
			return
		}
		referredBy = &referrer.ID
		now := time.Now()
		referralUsedAt = &now
	}

	// Create user
	newUser := models.User{
		Password:       string(hashedPassword),
		Email:          reqBody.Email,
		RoleID:         role.ID,
		ReferralCode:   referralCode,
		ReferredBy:     referredBy,
		ReferralUsedAt: referralUsedAt,
		IsApproved:     false,
	}

	if err := db.Create(&newUser).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create user"})
		return
	}

	// Create user details
	details := models.DetailsUser{
		UserID:      newUser.ID,
		Fullname:    reqBody.Fullname,
		PhoneNumber: reqBody.PhoneNumber,
	}

	if err := db.Create(&details).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to save user details"})
		return
	}

	// Generate token
	token, err := generateToken(newUser.ID, reqBody.Fullname, role.RoleName)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "User registered successfully.",
		"token":   token,
	})
}

func generateUniqueReferralCode(db *gorm.DB) (string, error) {
	const chars = "abcdefghijklmnopqrstuvwxyz0123456789"
	const length = 8

	for {
		randomCode := make([]byte, length)
		for i := range randomCode {
			num, err := rand.Int(rand.Reader, big.NewInt(int64(len(chars))))
			if err != nil {
				return "", err
			}
			randomCode[i] = chars[num.Int64()]
		}
		referralCode := "gts/" + string(randomCode)

		var count int64
		if err := db.Model(&models.User{}).Where("referral_code = ?", referralCode).Count(&count).Error; err != nil {
			return "", err
		}

		if count == 0 {
			return referralCode, nil
		}
	}
}

func generateToken(userID uint, fullname, role string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"id":       userID,
		"fullname": fullname,
		"role":     role,
		"exp":      time.Now().Add(time.Hour).Unix(),
	})

	return token.SignedString([]byte(os.Getenv("TOKEN_JWT")))
}

// Login User
func LoginUser(c *gin.Context) {
	type RequestBody struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	if reqBody.Email == "" || reqBody.Password == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Email and password are required."})
		return
	}

	db := c.MustGet("db").(*gorm.DB)

	var user models.User
	if err := db.Where("email = ?", reqBody.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Email not found."})
		return
	}

	if !user.IsApproved {
		c.JSON(http.StatusForbidden, gin.H{"message": "Your account is not approved by admin yet."})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(reqBody.Password)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid password."})
		return
	}

	var role models.Role
	if err := db.First(&role, user.RoleID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to get user role"})
		return
	}

	token, err := generateLoginToken(user.ID, user.Email, role.RoleName)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Login successful.",
		"token":   token,
	})
}

func generateLoginToken(userID uint, email, role string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"id":    userID,
		"email": email,
		"role":  role,
		"exp":   time.Now().Add(7 * 24 * time.Hour).Unix(), // 7 days
	})

	return token.SignedString([]byte(os.Getenv("TOKEN_JWT")))
}

// Logout User
func LogoutUser(c *gin.Context) {
	authHeader := c.GetHeader("Authorization")
	tokenString := strings.TrimPrefix(authHeader, "Bearer ")

	if tokenString == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Token is required for logout."})
		return
	}

	// Add token to blacklist
	middleware.AddTokenToBlacklist(tokenString)

	c.JSON(http.StatusOK, gin.H{"message": "Logout successful. Token has been invalidated."})
}

// Get User Data
func GetUserData(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "User data not found"})
		return
	}

	db := c.MustGet("db").(*gorm.DB)

	// Struct untuk respons referral
	type ReferralItem struct {
		ID             uint       `json:"id"`
		Email          string     `json:"email"`
		CreatedAt      time.Time  `json:"created_at"`
		ReferralUsedAt *time.Time `json:"referral_used_at,omitempty"`
		Fullname       string     `json:"fullname"`
	}

	type UserResponse struct {
		ID           uint           `json:"id"`
		Email        string         `json:"email"`
		CreatedAt    time.Time      `json:"created_at"`
		Role         string         `json:"role"`
		Points       int            `json:"points"`
		ReferralCode string         `json:"referralCode"`
		Fullname     string         `json:"fullname"`
		PhoneNumber  string         `json:"phone_number"`
		PhotoProfile string         `json:"photo_profile"`
		Referrals    []ReferralItem `json:"referrals"`
	}

	var user models.User
	if err := db.
		Preload("Role").
		Preload("Points").
		Preload("Details").
		Preload("Referrals").
		Preload("Referrals.Details").
		First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		return
	}

	points := 0
	if user.Points != nil {
		points = user.Points.Points
	}

	response := UserResponse{
		ID:           user.ID,
		Email:        user.Email,
		CreatedAt:    user.CreatedAt,
		Role:         user.Role.RoleName,
		Points:       points,
		ReferralCode: user.ReferralCode,
	}

	if user.Details != nil {
		response.Fullname = user.Details.Fullname
		response.PhoneNumber = user.Details.PhoneNumber
		response.PhotoProfile = user.Details.PhotoProfile
	}

	// Isi data referrals
	response.Referrals = make([]ReferralItem, 0)
	for _, referral := range user.Referrals {
		fullname := ""
		if referral.Details != nil {
			fullname = referral.Details.Fullname
		}

		response.Referrals = append(response.Referrals, ReferralItem{
			ID:             referral.ID,
			Email:          referral.Email,
			CreatedAt:      referral.CreatedAt,
			ReferralUsedAt: referral.ReferralUsedAt,
			Fullname:       fullname,
		})
	}

	c.JSON(http.StatusOK, response)
}

// Update User
func UpdateUser(c *gin.Context) {
	userID := c.Param("userId")

	type RequestBody struct {
		Fullname    string `json:"fullname"`
		PhoneNumber string `json:"phone_number"`
		Email       string `json:"email"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	db := c.MustGet("db").(*gorm.DB)

	var user models.User
	if err := db.Preload("Details").First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		return
	}

	// Update email
	if reqBody.Email != "" {
		user.Email = reqBody.Email
	}

	// Update user details
	if user.Details == nil {
		// Create new details
		details := models.DetailsUser{
			UserID:      user.ID,
			Fullname:    reqBody.Fullname,
			PhoneNumber: reqBody.PhoneNumber,
		}
		if err := db.Create(&details).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create user details"})
			return
		}
	} else {
		if reqBody.Fullname != "" {
			user.Details.Fullname = reqBody.Fullname
		}
		if reqBody.PhoneNumber != "" {
			user.Details.PhoneNumber = reqBody.PhoneNumber
		}
		if err := db.Save(user.Details).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update user details"})
			return
		}
	}

	if err := db.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User updated successfully"})
}

// Reset Password Functions
func RequestResetOtp(c *gin.Context) {
	// Implement email sending logic
}

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

func ResetPassword(c *gin.Context) {
	type RequestBody struct {
		Email           string `json:"email"`
		NewPassword     string `json:"newPassword"`
		ConfirmPassword string `json:"confirmPassword"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	// Validasi password
	if reqBody.NewPassword != reqBody.ConfirmPassword {
		c.JSON(http.StatusBadRequest, gin.H{"message": "New password and confirmation do not match"})
		return
	}

	// Validasi kekuatan password (minimal 8 karakter, huruf, angka, karakter khusus)
	if len(reqBody.NewPassword) < 8 {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Password must be at least 8 characters long"})
		return
	}

	hasLetter := false
	hasNumber := false
	hasSpecial := false

	for _, char := range reqBody.NewPassword {
		switch {
		case (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z'):
			hasLetter = true
		case char >= '0' && char <= '9':
			hasNumber = true
		case strings.ContainsAny(string(char), "!@#$%^&*(),.?\":{}|<>"):
			hasSpecial = true
		}
	}

	if !hasLetter || !hasNumber || !hasSpecial {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "Password must contain at least one letter, one number, and one special character",
		})
		return
	}

	db := c.MustGet("db").(*gorm.DB)

	var user models.User
	if err := db.Where("email = ?", reqBody.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		return
	}

	// Hash password baru
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(reqBody.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to hash password"})
		return
	}

	// Update password dan reset OTP fields
	user.Password = string(hashedPassword)
	user.ResetOtp = nil
	user.ResetOtpExpires = nil

	if err := db.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to reset password"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Password reset successfully"})
}

func GetResetOtpExpiry(c *gin.Context) {
	type RequestBody struct {
		Email string `json:"email"`
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

	if user.ResetOtpExpires == nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "No OTP requested"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"expiryTime": user.ResetOtpExpires})
}

// Update FCM Token
func UpdateFcmToken(c *gin.Context) {
	type RequestBody struct {
		FCMToken string `json:"fcm_token"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	if reqBody.FCMToken == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "FCM token is required"})
		return
	}

	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "User not authenticated"})
		return
	}

	db := c.MustGet("db").(*gorm.DB)

	var user models.User
	if err := db.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		return
	}

	user.FCMToken = reqBody.FCMToken
	if err := db.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update FCM token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":   "FCM token updated",
		"fcm_token": user.FCMToken,
	})
}
