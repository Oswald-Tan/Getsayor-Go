package app

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type HargaPoinController struct {
	DB *gorm.DB
}

func NewHargaPoinController(db *gorm.DB) *HargaPoinController {
	return &HargaPoinController{DB: db}
}

// GetHargaPoin mendapatkan semua harga poin
func (ctrl *HargaPoinController) GetHargaPoin(c *gin.Context) {
	var hargaPoin []models.HargaPoin
	if err := ctrl.DB.Find(&hargaPoin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, hargaPoin)
}

// GetHargaPoinById mendapatkan harga poin berdasarkan ID
func (ctrl *HargaPoinController) GetHargaPoinById(c *gin.Context) {
	id := c.Param("id")

	var hargaPoin models.HargaPoin
	if err := ctrl.DB.First(&hargaPoin, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"message": "Harga Poin not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		}
		return
	}

	c.JSON(http.StatusOK, hargaPoin)
}

// CreateHargaPoin membuat harga poin baru
func (ctrl *HargaPoinController) CreateHargaPoin(c *gin.Context) {
	type RequestBody struct {
		Harga int `json:"harga" binding:"required"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	// Cek apakah sudah ada data harga poin
	var existingHarga models.HargaPoin
	if err := ctrl.DB.First(&existingHarga).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Harga Poin already exists"})
		return
	}

	newHargaPoin := models.HargaPoin{
		Harga: reqBody.Harga,
	}

	if err := ctrl.DB.Create(&newHargaPoin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Harga Poin created successfully",
		"data":    newHargaPoin,
	})
}

// UpdateHargaPoin mengupdate harga poin
func (ctrl *HargaPoinController) UpdateHargaPoin(c *gin.Context) {
	// Cari harga poin yang pertama (asumsi hanya ada satu)
	var hargaPoin models.HargaPoin
	if err := ctrl.DB.First(&hargaPoin).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"message": "Harga Poin not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		}
		return
	}

	type RequestBody struct {
		Harga int `json:"harga" binding:"required"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	// Update data harga poin
	hargaPoin.Harga = reqBody.Harga

	if err := ctrl.DB.Save(&hargaPoin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Harga Poin updated successfully",
		"data":    hargaPoin,
	})
}

// DeleteHargaPoin menghapus harga poin
func (ctrl *HargaPoinController) DeleteHargaPoin(c *gin.Context) {
	// Cari harga poin yang pertama (asumsi hanya ada satu)
	var hargaPoin models.HargaPoin
	if err := ctrl.DB.First(&hargaPoin).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"message": "Harga Poin not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		}
		return
	}

	if err := ctrl.DB.Delete(&hargaPoin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Harga Poin deleted successfully"})
}
