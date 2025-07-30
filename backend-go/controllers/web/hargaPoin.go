package web

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

// GetHargaPoin handles GET /api/harga-poin
func (ctrl *HargaPoinController) GetHargaPoin(c *gin.Context) {
	var hargaPoin []models.HargaPoin

	// Ambil semua data harga poin
	if err := ctrl.DB.Find(&hargaPoin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Database error: " + err.Error(),
		})
		return
	}

	// Format response
	response := make([]map[string]interface{}, len(hargaPoin))
	for i, item := range hargaPoin {
		response[i] = map[string]interface{}{
			"id":    item.ID,
			"harga": item.Harga,
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    response,
	})
}

// GetHargaPoinById handles GET /api/harga-poin/:id
func (ctrl *HargaPoinController) GetHargaPoinById(c *gin.Context) {
	id := c.Param("id")
	var hargaPoin models.HargaPoin

	// Cari harga poin berdasarkan ID
	if err := ctrl.DB.First(&hargaPoin, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{
				"success": false,
				"message": "Harga Poin not found",
			})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Database error: " + err.Error(),
			})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": map[string]interface{}{
			"id":    hargaPoin.ID,
			"harga": hargaPoin.Harga,
		},
	})
}

type CreateHargaPoinRequest struct {
	Harga int `json:"harga" binding:"required"`
}

// CreateHargaPoin handles POST /api/harga-poin
func (ctrl *HargaPoinController) CreateHargaPoin(c *gin.Context) {
	var req CreateHargaPoinRequest

	// Bind request body
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	// Validasi harga
	if req.Harga <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Harga must be a positive number",
		})
		return
	}

	// Cek apakah sudah ada harga poin
	var existingHargaPoin models.HargaPoin
	if err := ctrl.DB.First(&existingHargaPoin).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Harga Poin already exists",
		})
		return
	}

	// Buat harga poin baru
	hargaPoin := models.HargaPoin{
		Harga: req.Harga,
	}

	if err := ctrl.DB.Create(&hargaPoin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to create Harga Poin: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "Harga Poin created successfully",
		"data": map[string]interface{}{
			"id":    hargaPoin.ID,
			"harga": hargaPoin.Harga,
		},
	})
}

type UpdateHargaPoinRequest struct {
	Harga int `json:"harga" binding:"required"`
}

// UpdateHargaPoin handles PATCH /api/harga-poin/:id
func (ctrl *HargaPoinController) UpdateHargaPoin(c *gin.Context) {
	id := c.Param("id")
	var req UpdateHargaPoinRequest

	// Bind request body
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	// Validasi harga
	if req.Harga <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Harga must be a positive number",
		})
		return
	}

	// Cari harga poin berdasarkan ID
	var hargaPoin models.HargaPoin
	if err := ctrl.DB.First(&hargaPoin, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{
				"success": false,
				"message": "Harga Poin not found",
			})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Database error: " + err.Error(),
			})
		}
		return
	}

	// Update harga
	hargaPoin.Harga = req.Harga

	if err := ctrl.DB.Save(&hargaPoin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to update Harga Poin: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Harga Poin updated successfully",
		"data": map[string]interface{}{
			"id":    hargaPoin.ID,
			"harga": hargaPoin.Harga,
		},
	})
}

// DeleteHargaPoin handles DELETE /api/harga-poin/:id
func (ctrl *HargaPoinController) DeleteHargaPoin(c *gin.Context) {
	id := c.Param("id")

	// Cari harga poin berdasarkan ID
	var hargaPoin models.HargaPoin
	if err := ctrl.DB.First(&hargaPoin, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{
				"success": false,
				"message": "Harga Poin not found",
			})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Database error: " + err.Error(),
			})
		}
		return
	}

	// Hapus harga poin
	if err := ctrl.DB.Delete(&hargaPoin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to delete Harga Poin: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Harga Poin deleted successfully",
	})
}
