package app

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type BankAccountController struct {
	DB *gorm.DB
}

func NewBankAccountController(db *gorm.DB) *BankAccountController {
	return &BankAccountController{DB: db}
}

// CreateOrUpdateBankAccount membuat atau mengupdate rekening bank
func (ctrl *BankAccountController) CreateOrUpdateBankAccount(c *gin.Context) {
	type RequestBody struct {
		BankName      string `json:"bankName" binding:"required"`
		AccountNumber string `json:"accountNumber" binding:"required"`
		AccountHolder string `json:"accountHolder" binding:"required"`
		UserID        uint   `json:"userId" binding:"required"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	tx := ctrl.DB.Begin()

	// Cek apakah rekening bank sudah ada
	var existingAccount models.BankAccount
	if err := tx.Where("user_id = ?", reqBody.UserID).First(&existingAccount).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			// Buat rekening baru jika belum ada
			newAccount := models.BankAccount{
				UserID:        reqBody.UserID,
				BankName:      reqBody.BankName,
				AccountNumber: reqBody.AccountNumber,
				AccountHolder: reqBody.AccountHolder,
			}

			if err := tx.Create(&newAccount).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create bank account"})
				return
			}

			tx.Commit()
			c.JSON(http.StatusCreated, newAccount)
		} else {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Error checking bank account"})
		}
		return
	}

	// Update rekening yang sudah ada
	existingAccount.BankName = reqBody.BankName
	existingAccount.AccountNumber = reqBody.AccountNumber
	existingAccount.AccountHolder = reqBody.AccountHolder

	if err := tx.Save(&existingAccount).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update bank account"})
		return
	}

	tx.Commit()
	c.JSON(http.StatusOK, existingAccount)
}

// GetBankAccountByUserId mendapatkan rekening bank berdasarkan user ID
func (ctrl *BankAccountController) GetBankAccountByUserId(c *gin.Context) {
	userID := c.Param("userId")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "User ID is required"})
		return
	}

	var bankAccount models.BankAccount
	if err := ctrl.DB.Where("user_id = ?", userID).First(&bankAccount).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"message": "Bank account not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Error retrieving bank account"})
		}
		return
	}

	c.JSON(http.StatusOK, bankAccount)
}

// DeleteBankAccount menghapus rekening bank berdasarkan user ID
func (ctrl *BankAccountController) DeleteBankAccount(c *gin.Context) {
	userID := c.Param("userId")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "User ID is required"})
		return
	}

	tx := ctrl.DB.Begin()

	// Cari dan hapus rekening bank
	result := tx.Where("user_id = ?", userID).Delete(&models.BankAccount{})
	if result.Error != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error deleting bank account"})
		return
	}

	if result.RowsAffected == 0 {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"message": "Bank account not found"})
		return
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{"message": "Bank account deleted successfully"})
}
