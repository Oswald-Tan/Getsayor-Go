package app

import (
	"backend-go/config"
	"backend-go/middleware"
	"backend-go/models"
	"crypto/rand"
	"fmt"
	"log"
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
		reqBody.PhoneNumber == "" || reqBody.RoleName == "" || reqBody.ReferralCode == "" { // Tambahkan validasi referralCode
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "Fullname, password, email, phone number, role, and referral code are required.",
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
	var referrer models.User
	if err := db.Where("referral_code = ?", reqBody.ReferralCode).First(&referrer).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid referral code."})
		return
	}
	referredBy = &referrer.ID
	now := time.Now()
	referralUsedAt = &now

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

	statsCtrl := NewUserStatsAppController(db)
	if _, err := statsCtrl.CreateOrUpdateUserStats(user.ID); err != nil {
		log.Printf("Failed to update user stats: %v", err)
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

	type ReferralItem struct {
		ID                 uint       `json:"id"`
		Email              string     `json:"email"`
		CreatedAt          time.Time  `json:"created_at"`
		ReferralUsedAt     *time.Time `json:"referral_used_at,omitempty"`
		Fullname           string     `json:"fullname"`
		MonthlySpent       int        `json:"monthly_spent"`         // Total belanja bulan ini (dari Pesanan)
		MonthlyBonus       int        `json:"monthly_bonus"`         // Bonus bulan ini (dari AfiliasiBonus) - Level 1
		MonthlyBonusLevel2 int        `json:"monthly_bonus_level2"`  // Bonus level 2 bulan ini
		IsEligibleForBonus bool       `json:"is_eligible_for_bonus"` // Apakah eligible untuk bonus
		EligibleOrders     int        `json:"eligible_orders"`       // Jumlah transaksi eligible (dari AfiliasiBonus)
	}

	type UserResponse struct {
		ID               uint           `json:"id"`
		Email            string         `json:"email"`
		CreatedAt        time.Time      `json:"created_at"`
		Role             string         `json:"role"`
		Points           int            `json:"points"`
		ReferralCode     string         `json:"referralCode"`
		Fullname         string         `json:"fullname"`
		PhoneNumber      string         `json:"phone_number"`
		PhotoProfile     string         `json:"photo_profile"`
		Referrals        []ReferralItem `json:"referrals"`
		TotalBonusLevel1 int            `json:"total_bonus_level1"` // Total bonus level 1
		TotalBonusLevel2 int            `json:"total_bonus_level2"` // Total bonus level 2
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
	now := time.Now()
	startOfMonth := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
	endOfMonth := startOfMonth.AddDate(0, 1, 0).Add(-time.Nanosecond)

	// Hitung total bonus level 1 dan level 2
	totalBonusLevel1 := 0
	totalBonusLevel2 := 0

	for _, referral := range user.Referrals {
		fullname := ""
		if referral.Details != nil {
			fullname = referral.Details.Fullname
		}

		type BonusSummary struct {
			TotalBonus float64 `gorm:"column:total_bonus"`
			Count      int64   `gorm:"column:transaction_count"`
		}

		var bonusSummaryLevel1 BonusSummary

		// QUERY 1: Ambil data bonus LEVEL 1 dari AFILIASI_BONUS yang terkait dengan PESANAN DELIVERED
		err := db.Model(&models.AfiliasiBonus{}).
			Joins("JOIN pesanan ON afiliasi_bonus.pesanan_id = pesanan.id").
			Where("afiliasi_bonus.user_id = ? AND afiliasi_bonus.referral_user_id = ? AND afiliasi_bonus.bonus_level = ? AND pesanan.status = ? AND afiliasi_bonus.status IN (?, ?) AND afiliasi_bonus.bonus_received_at BETWEEN ? AND ?",
				user.ID,                 // User yang mendapatkan bonus
				referral.ID,             // User yang direferral
				1,                       // Bonus level 1
				models.PesananDelivered, // HANYA pesanan dengan status delivered
				models.BonusPending,
				models.BonusClaimed,
				startOfMonth,
				endOfMonth).
			Select("COALESCE(SUM(afiliasi_bonus.bonus_amount), 0) as total_bonus, COUNT(*) as transaction_count").
			Scan(&bonusSummaryLevel1).Error

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to calculate monthly bonus level 1"})
			return
		}

		// QUERY 2: Ambil data bonus LEVEL 2 dari AFILIASI_BONUS yang terkait dengan PESANAN DELIVERED
		var bonusSummaryLevel2 BonusSummary
		err = db.Model(&models.AfiliasiBonus{}).
			Joins("JOIN pesanan ON afiliasi_bonus.pesanan_id = pesanan.id").
			Joins("JOIN users AS level2_user ON afiliasi_bonus.referral_user_id = level2_user.id").
			Where("afiliasi_bonus.user_id = ? AND afiliasi_bonus.bonus_level = ? AND pesanan.status = ? AND afiliasi_bonus.status IN (?, ?) AND afiliasi_bonus.bonus_received_at BETWEEN ? AND ? AND level2_user.referred_by = ?",
				user.ID,                 // User yang mendapatkan bonus (user A)
				2,                       // Bonus level 2
				models.PesananDelivered, // HANYA pesanan dengan status delivered
				models.BonusPending,
				models.BonusClaimed,
				startOfMonth,
				endOfMonth,
				referral.ID, // Harus berasal dari user yang diundang oleh referral saat ini
			).
			Select("COALESCE(SUM(afiliasi_bonus.bonus_amount), 0) as total_bonus, COUNT(*) as transaction_count").
			Scan(&bonusSummaryLevel2).Error

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to calculate monthly bonus level 2"})
			return
		}

		// QUERY 3: Ambil total belanja DELIVERED untuk referral
		var monthlySpent int
		err = db.Model(&models.Pesanan{}).
			Where("user_id = ? AND status = ? AND created_at BETWEEN ? AND ?",
				referral.ID,             // User yang direferral
				models.PesananDelivered, // HANYA status delivered
				startOfMonth,
				endOfMonth).
			Select("COALESCE(SUM(total_bayar), 0)").
			Scan(&monthlySpent).Error

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to calculate monthly spent"})
			return
		}

		// Tentukan eligibility berdasarkan PESANAN DELIVERED
		monthlyBonusLevel1 := int(bonusSummaryLevel1.TotalBonus)
		monthlyBonusLevel2 := int(bonusSummaryLevel2.TotalBonus)
		eligibleOrdersCount := int(bonusSummaryLevel1.Count)

		// Eligibility: Ada bonus HANYA jika ada pesanan delivered >= 200.000
		hasEligibleDeliveredOrder := monthlySpent >= 200000 && eligibleOrdersCount > 0

		// Jika tidak ada pesanan delivered yang eligible, set bonus menjadi 0
		if !hasEligibleDeliveredOrder {
			monthlyBonusLevel1 = 0
			monthlyBonusLevel2 = 0
		}

		// Tambahkan ke total bonus
		totalBonusLevel1 += monthlyBonusLevel1
		totalBonusLevel2 += monthlyBonusLevel2

		response.Referrals = append(response.Referrals, ReferralItem{
			ID:                 referral.ID,
			Email:              referral.Email,
			CreatedAt:          referral.CreatedAt,
			ReferralUsedAt:     referral.ReferralUsedAt,
			Fullname:           fullname,
			MonthlySpent:       monthlySpent,              // Dari PESANAN DELIVERED
			MonthlyBonus:       monthlyBonusLevel1,        // Bonus level 1 dari AFILIASI_BONUS (hanya untuk delivered)
			MonthlyBonusLevel2: monthlyBonusLevel2,        // Bonus level 2 dari AFILIASI_BONUS (hanya untuk delivered)
			IsEligibleForBonus: hasEligibleDeliveredOrder, // Berdasarkan delivered orders
			EligibleOrders:     eligibleOrdersCount,       // Jumlah transaksi eligible dari AFILIASI_BONUS
		})
	}

	response.TotalBonusLevel1 = totalBonusLevel1
	response.TotalBonusLevel2 = totalBonusLevel2

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
	type RequestBody struct {
		Email string `json:"email" binding:"required,email"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	db := c.MustGet("db").(*gorm.DB)

	var user models.User
	if err := db.Where("email = ?", reqBody.Email).First(&user).Error; err != nil {
		// Kembalikan status 404 jika email tidak ditemukan
		c.JSON(http.StatusNotFound, gin.H{"message": "Email tidak terdaftar di sistem kami"})
		return
	}

	// Generate OTP (6 digit)
	otp, err := generateOtp(6)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Gagal menghasilkan OTP"})
		return
	}

	// Set OTP dan waktu kadaluarsa (10 menit)
	expiryTime := time.Now().Add(10 * time.Minute)
	user.ResetOtp = &otp
	user.ResetOtpExpires = &expiryTime

	if err := db.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Gagal menyimpan OTP"})
		return
	}

	// Siapkan konten email
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

	// Kirim email menggunakan mailer
	mailer := config.NewMailer()
	if err := mailer.SendEmail(reqBody.Email, subject, body); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Gagal mengirim email OTP"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Jika email terdaftar, OTP telah dikirim",
		"success": true,
	})
}

func generateOtp(length int) (string, error) {
	const digits = "0123456789"
	otp := make([]byte, length)
	for i := range otp {
		num, err := rand.Int(rand.Reader, big.NewInt(int64(len(digits))))
		if err != nil {
			return "", err
		}
		otp[i] = digits[num.Int64()]
	}
	return string(otp), nil
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

	c.JSON(http.StatusOK, gin.H{"message": "OTP berhasil diverifikasi"})
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
