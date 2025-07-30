package web

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"

	"backend-go/models"
)

type UserController struct {
	DB *gorm.DB
}

func NewUserController(db *gorm.DB) *UserController {
	return &UserController{DB: db}
}

// GetUsers returns paginated list of users
func (ctrl *UserController) GetUsers(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	search := c.Query("search")
	offset := page * limit

	var totalRows int64
	var users []models.User

	// Build base query
	query := ctrl.DB.Model(&models.User{}).
		Preload("Details").
		Preload("Role").
		Preload("Points").
		Where("role_id = ?", 2)

	// Add search condition if provided
	if search != "" {
		query = query.Joins("JOIN details_users ON details_users.user_id = users.id").
			Where("details_users.fullname LIKE ?", "%"+search+"%")
	}

	// Count total users
	if err := query.Count(&totalRows).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Get paginated users
	query = query.Offset(offset).Limit(limit)

	// Handle ordering - hanya tambahkan jika ada search
	if search != "" {
		query = query.Order("details_users.fullname ASC")
	} else {
		query = query.Order("users.id ASC") // Default ordering
	}

	if err := query.Find(&users).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Prepare response
	response := make([]gin.H, len(users))
	for i, user := range users {
		points := 0
		if user.Points != nil {
			points = user.Points.Points
		}

		fullname := ""
		if user.Details != nil {
			fullname = user.Details.Fullname
		}

		roleName := ""
		if user.Role != nil {
			roleName = user.Role.RoleName
		}

		response[i] = gin.H{
			"id":       user.ID,
			"fullname": fullname,
			"email":    user.Email,
			"role":     roleName,
			"points":   points,
		}
	}

	totalPages := (int(totalRows) + limit - 1) / limit

	c.JSON(http.StatusOK, gin.H{
		"data":       response,
		"page":       page,
		"limit":      limit,
		"totalPages": totalPages,
		"totalRows":  totalRows,
	})
}

// GetUserApprove returns users waiting for approval
func (ctrl *UserController) GetUserApprove(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	search := c.Query("search")
	offset := page * limit

	var totalRows int64
	var users []models.User

	query := ctrl.DB.Model(&models.User{}).
		Where("is_approved = ? AND role_id = ?", false, 2).
		Preload("Details").
		Preload("Role")

	if search != "" {
		query = query.Joins("JOIN details_users ON details_users.user_id = users.id").
			Where("details_users.fullname LIKE ?", "%"+search+"%")
	}

	// Count total users
	if err := query.Count(&totalRows).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Get paginated users
	if err := query.Offset(offset).Limit(limit).
		Order("created_at DESC").
		Find(&users).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Prepare response
	response := make([]gin.H, len(users))
	for i, user := range users {
		response[i] = gin.H{
			"id":         user.ID,
			"fullname":   user.Details.Fullname,
			"email":      user.Email,
			"role":       user.Role.RoleName,
			"isApproved": user.IsApproved,
		}
	}

	totalPages := (int(totalRows) + limit - 1) / limit

	c.JSON(http.StatusOK, gin.H{
		"data":       response,
		"page":       page,
		"limit":      limit,
		"totalPages": totalPages,
		"totalRows":  totalRows,
	})
}

// ApproveUsers approves multiple users
func (ctrl *UserController) ApproveUsers(c *gin.Context) {
	var request struct {
		UserIds []uint `json:"userIds"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	if len(request.UserIds) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No user IDs provided"})
		return
	}

	result := ctrl.DB.Model(&models.User{}).
		Where("id IN ?", request.UserIds).
		Update("is_approved", true)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":      "Users approved successfully",
		"updatedCount": result.RowsAffected,
	})
}

// ApproveUser approves a single user
func (ctrl *UserController) ApproveUser(c *gin.Context) {
	var request struct {
		UserId uint `json:"userId"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	var user models.User
	if err := ctrl.DB.First(&user, request.UserId).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	user.IsApproved = true
	if err := ctrl.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User approved successfully"})
}

// GetTotalUsers returns total count of users
func (ctrl *UserController) GetTotalUsers(c *gin.Context) {
	var count int64
	if err := ctrl.DB.Model(&models.User{}).
		Where("role_id = ?", 2).
		Count(&count).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"totalUser": count})
}

// GetUserDetails returns user details
func (ctrl *UserController) GetUserDetails(c *gin.Context) {
	id := c.Param("id")

	var details models.DetailsUser
	if err := ctrl.DB.Preload("User").
		Where("user_id = ?", id).
		First(&details).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			var user models.User
			if err := ctrl.DB.First(&user, id).Error; err != nil {
				c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
				return
			}

			c.JSON(http.StatusOK, gin.H{
				"email":         user.Email,
				"fullname":      "-",
				"phone_number":  "-",
				"photo_profile": "-",
			})
			return
		}

		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"email":         details.User.Email,
		"id":            details.UserID,
		"fullname":      details.Fullname,
		"phone_number":  details.PhoneNumber,
		"photo_profile": details.PhotoProfile,
	})
}

// GetUserPoints returns user points
func (ctrl *UserController) GetUserPoints(c *gin.Context) {
	id := c.Param("id")

	var points models.UserPoints
	if err := ctrl.DB.Preload("User.Details").
		Where("user_id = ?", id).
		First(&points).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			var user models.User
			if err := ctrl.DB.Preload("Details").
				First(&user, id).Error; err != nil {
				c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
				return
			}

			c.JSON(http.StatusOK, gin.H{
				"points":   0,
				"email":    user.Email,
				"id":       user.ID,
				"fullname": user.Details.Fullname,
			})
			return
		}

		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"points":   points.Points,
		"email":    points.User.Email,
		"id":       points.UserID,
		"fullname": points.User.Details.Fullname,
	})
}

// UpdateUserPoints updates user points
func (ctrl *UserController) UpdateUserPoints(c *gin.Context) {
	userId := c.Param("userId")

	var request struct {
		Points int `json:"points"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	var user models.User
	if err := ctrl.DB.First(&user, userId).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	points := models.UserPoints{
		UserID: user.ID,
		Points: request.Points,
	}

	if err := ctrl.DB.Where("user_id = ?", user.ID).
		Assign(points).
		FirstOrCreate(&points).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Points updated successfully",
		"data": gin.H{
			"userId": points.UserID,
			"points": points.Points,
		},
	})
}

// GetUserById returns a single user by ID
func (ctrl *UserController) GetUserById(c *gin.Context) {
	id := c.Param("id")

	var user models.User
	if err := ctrl.DB.Preload("Details").
		Preload("Role").
		First(&user, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"id":       user.ID,
		"fullname": user.Details.Fullname,
		"email":    user.Email,
		"role":     user.Role.RoleName,
	})
}

func generateUniqueReferralCode(db *gorm.DB) (string, error) {
	const charset = "abcdefghijklmnopqrstuvwxyz0123456789"
	const prefix = "gs/"
	const length = 8
	maxAttempts := 10

	for i := 0; i < maxAttempts; i++ {
		randomCode := make([]byte, length)
		for j := 0; j < length; j++ {
			num, err := rand.Int(rand.Reader, big.NewInt(int64(len(charset))))
			if err != nil {
				return "", fmt.Errorf("failed to generate random number: %v", err)
			}
			randomCode[j] = charset[num.Int64()]
		}
		referralCode := prefix + string(randomCode)

		var count int64
		if err := db.Model(&models.User{}).
			Where("referral_code = ?", referralCode).
			Count(&count).Error; err != nil {
			return "", fmt.Errorf("database error: %v", err)
		}

		if count == 0 {
			return referralCode, nil
		}
	}

	return "", fmt.Errorf("failed to generate unique referral code after %d attempts", maxAttempts)
}

func (ctrl *UserController) CreateUser(c *gin.Context) {
	var request struct {
		Fullname        string `json:"fullname" binding:"required"`
		Email           string `json:"email" binding:"required,email"`
		Password        string `json:"password" binding:"required"`
		ConfirmPassword string `json:"confirmPassword" binding:"required"`
		RoleName        string `json:"roleName" binding:"required"`
	}

	// Bind and validate request
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if request.Password != request.ConfirmPassword {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Passwords do not match"})
		return
	}

	// Check email uniqueness
	var count int64
	if err := ctrl.DB.Model(&models.User{}).
		Where("email = ?", request.Email).
		Count(&count).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if count > 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "Email already in use"})
		return
	}

	// Get role
	var role models.Role
	if err := ctrl.DB.Where("role_name = ?", request.RoleName).
		First(&role).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Role not found"})
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(request.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// Generate unique referral code
	referralCode, err := generateUniqueReferralCode(ctrl.DB)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to generate referral code",
			"details": err.Error(),
		})
		return
	}

	// Start transaction
	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Create user
	user := models.User{
		Email:        request.Email,
		Password:     string(hashedPassword),
		RoleID:       role.ID,
		ReferralCode: referralCode,
		IsApproved:   false,
	}

	if err := tx.Create(&user).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Create user details
	details := models.DetailsUser{
		UserID:   user.ID,
		Fullname: request.Fullname,
	}

	if err := tx.Create(&details).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Commit transaction
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "User created successfully",
		"data": gin.H{
			"id":           user.ID,
			"fullname":     details.Fullname,
			"email":        user.Email,
			"role":         role.RoleName,
			"referralCode": user.ReferralCode,
		},
	})
}

// UpdateUser updates an existing user
func (ctrl *UserController) UpdateUser(c *gin.Context) {
	id := c.Param("id")

	var request struct {
		Fullname        string `json:"fullname"`
		Email           string `json:"email"`
		Password        string `json:"password"`
		ConfirmPassword string `json:"confirmPassword"`
		RoleName        string `json:"roleName"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get existing user
	var user models.User
	if err := ctrl.DB.Preload("Details").
		First(&user, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	// Update password if provided
	if request.Password != "" {
		if request.Password != request.ConfirmPassword {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Passwords do not match"})
			return
		}

		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(request.Password), bcrypt.DefaultCost)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
			return
		}
		user.Password = string(hashedPassword)
	}

	// Update email if provided
	if request.Email != "" {
		user.Email = request.Email
	}

	// Update role if provided
	if request.RoleName != "" {
		var role models.Role
		if err := ctrl.DB.Where("role_name = ?", request.RoleName).
			First(&role).Error; err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Role not found"})
			return
		}
		user.RoleID = role.ID
	}

	// Update user
	if err := ctrl.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Update details if fullname provided
	if request.Fullname != "" {
		if err := ctrl.DB.Model(&user.Details).
			Update("fullname", request.Fullname).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "User updated successfully"})
}

// DeleteUser deletes a user
func (ctrl *UserController) DeleteUser(c *gin.Context) {
	id := c.Param("id")

	// Mulai transaction
	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Hapus details terlebih dahulu
	if err := tx.Where("user_id = ?", id).Delete(&models.DetailsUser{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Hapus user
	if err := tx.Delete(&models.User{}, id).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Commit transaction
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User deleted successfully"})
}
