package web

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type SettingController struct {
	DB *gorm.DB
}

func NewSettingController(db *gorm.DB) *SettingController {
	return &SettingController{DB: db}
}

// GetHargaPoin handles GET /api/settings/harga-poin
func (ctrl *SettingController) GetHargaPoin(c *gin.Context) {
	var setting models.Setting

	// Cari setting dengan key "hargaPoin"
	if err := ctrl.DB.Where("key = ?", "hargaPoin").First(&setting).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{
				"success": false,
				"message": "Harga Poin setting not found",
			})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Database error: " + err.Error(),
			})
		}
		return
	}

	// Konversi value ke integer
	hargaPoin, err := strconv.Atoi(setting.Value)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Invalid hargaPoin value: " + setting.Value,
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":   true,
		"hargaPoin": hargaPoin,
	})
}

type SetHargaPoinRequest struct {
	HargaPoin any `json:"hargaPoin" binding:"required"`
}

func (ctrl *SettingController) SetHargaPoin(c *gin.Context) {
	var req SetHargaPoinRequest

	// Bind request body
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	// Konversi ke int
	var hargaPoinInt int
	switch v := req.HargaPoin.(type) {
	case float64:
		hargaPoinInt = int(v)
	case string:
		var err error
		hargaPoinInt, err = strconv.Atoi(v)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid hargaPoin value: " + v,
			})
			return
		}
	case int:
		hargaPoinInt = v
	default:
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid hargaPoin type",
		})
		return
	}

	// Validasi harga poin harus angka positif
	if hargaPoinInt <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Harga Poin must be a positive number",
		})
		return
	}

	var setting models.Setting

	// Cari atau buat setting hargaPoin
	result := ctrl.DB.Where("key = ?", "hargaPoin").First(&setting)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			// Buat baru jika tidak ditemukan
			setting = models.Setting{
				Key:   "hargaPoin",
				Value: strconv.Itoa(hargaPoinInt),
			}
			if err := ctrl.DB.Create(&setting).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{
					"success": false,
					"message": "Failed to create setting: " + err.Error(),
				})
				return
			}
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Database error: " + result.Error.Error(),
			})
			return
		}
	} else {
		// Update jika sudah ada
		setting.Value = strconv.Itoa(hargaPoinInt)
		if err := ctrl.DB.Save(&setting).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Failed to update setting: " + err.Error(),
			})
			return
		}
	}

	// Perbarui hargaRp di semua product items (bukan di product)
	var productItems []models.ProductItem
	if err := ctrl.DB.Find(&productItems).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to fetch product items: " + err.Error(),
		})
		return
	}

	// Update hargaRp untuk semua product items
	for _, item := range productItems {
		// Skip jika hargaPoin item 0
		if item.HargaPoin == 0 {
			continue
		}

		// Hitung hargaRp baru
		item.HargaRp = item.HargaPoin * hargaPoinInt
		if err := ctrl.DB.Save(&item).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Failed to update product item: " + err.Error(),
			})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Harga Poin updated successfully",
		"data": gin.H{
			"hargaPoin":     hargaPoinInt,
			"updated_items": len(productItems),
		},
	})
}
