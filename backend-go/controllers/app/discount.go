package app

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type DiscountController struct {
	DB *gorm.DB
}

func NewDiscountController(db *gorm.DB) *DiscountController {
	return &DiscountController{DB: db}
}

// GetDiscountPoin mendapatkan semua discount
func (ctrl *DiscountController) GetDiscountPoin(c *gin.Context) {
	var discounts []struct {
		ID         uint    `json:"id"`
		Percentage float64 `json:"percentage"`
		Poin       int     `json:"poin"`
	}

	// Query dengan join
	if err := ctrl.DB.Model(&models.Discount{}).
		Select("discounts.id, discounts.percentage, poin.poin").
		Joins("JOIN poin ON poin.id = discounts.poin_id").
		Scan(&discounts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, discounts)
}

// GetDiscountPoinById mendapatkan discount berdasarkan ID
func (ctrl *DiscountController) GetDiscountPoinById(c *gin.Context) {
	id := c.Param("id")

	var discount struct {
		ID         uint    `json:"id"`
		Percentage float64 `json:"percentage"`
		PoinID     uint    `json:"poinId"`
		Poin       int     `json:"poin"`
	}

	// Query dengan join
	if err := ctrl.DB.Model(&models.Discount{}).
		Select("discounts.id, discounts.percentage, discounts.poin_id as poin_id, poin.poin").
		Joins("JOIN poin ON poin.id = discounts.poin_id").
		Where("discounts.id = ?", id).
		Scan(&discount).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	if discount.ID == 0 {
		c.JSON(http.StatusNotFound, gin.H{"message": "Discount not found"})
		return
	}

	c.JSON(http.StatusOK, discount)
}

// CreateDiscountPoin membuat discount baru
func (ctrl *DiscountController) CreateDiscountPoin(c *gin.Context) {
	type RequestBody struct {
		Percentage float64 `json:"percentage" binding:"required"`
		PoinID     uint    `json:"poinId" binding:"required"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	// Cek apakah poinID valid
	var poin models.Poin
	if err := ctrl.DB.First(&poin, reqBody.PoinID).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid poin ID"})
		return
	}

	// Cek apakah poinID sudah digunakan
	var existingDiscount models.Discount
	if err := ctrl.DB.Where("poin_id = ?", reqBody.PoinID).First(&existingDiscount).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"message": "Poin ID already used for another discount"})
		return
	}

	newDiscount := models.Discount{
		Percentage: reqBody.Percentage,
		PoinID:     reqBody.PoinID,
	}

	if err := ctrl.DB.Create(&newDiscount).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Discount created successfully",
		"data":    newDiscount,
	})
}

// UpdateDiscountPoin mengupdate discount
func (ctrl *DiscountController) UpdateDiscountPoin(c *gin.Context) {
	id := c.Param("id")

	type RequestBody struct {
		Percentage float64 `json:"percentage" binding:"required"`
		PoinID     uint    `json:"poinId" binding:"required"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	// Cari discount berdasarkan ID
	var discount models.Discount
	if err := ctrl.DB.First(&discount, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Discount not found"})
		return
	}

	// Cek apakah poinID valid
	var poin models.Poin
	if err := ctrl.DB.First(&poin, reqBody.PoinID).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid poin ID"})
		return
	}

	// Cek apakah poinID sudah digunakan oleh discount lain
	var existingDiscount models.Discount
	if err := ctrl.DB.
		Where("poin_id = ? AND id <> ?", reqBody.PoinID, id).
		First(&existingDiscount).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"message": "Poin ID already used for another discount"})
		return
	}

	// Update data discount
	discount.Percentage = reqBody.Percentage
	discount.PoinID = reqBody.PoinID

	if err := ctrl.DB.Save(&discount).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Discount updated successfully",
		"data":    discount,
	})
}

// DeleteDiscountPoin menghapus discount
func (ctrl *DiscountController) DeleteDiscountPoin(c *gin.Context) {
	id := c.Param("id")

	// Cari discount berdasarkan ID
	var discount models.Discount
	if err := ctrl.DB.First(&discount, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Discount not found"})
		return
	}

	if err := ctrl.DB.Delete(&discount).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Discount deleted successfully"})
}
