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
	HargaPoin interface{} `json:"hargaPoin" binding:"required"`
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
				Value: strconv.Itoa(hargaPoinInt), // Gunakan hargaPoinInt yang sudah dikonversi
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
		setting.Value = strconv.Itoa(hargaPoinInt) // Gunakan hargaPoinInt yang sudah dikonversi
		if err := ctrl.DB.Save(&setting).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Failed to update setting: " + err.Error(),
			})
			return
		}
	}

	// Perbarui hargaRp di semua produk
	var products []models.Product
	if err := ctrl.DB.Find(&products).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to fetch products: " + err.Error(),
		})
		return
	}

	// Update hargaRp untuk semua produk
	for _, product := range products {
		// Skip jika hargaPoin produk 0
		if product.HargaPoin == 0 {
			continue
		}

		// Gunakan hargaPoinInt yang sudah dikonversi
		product.HargaRp = product.HargaPoin * hargaPoinInt
		if err := ctrl.DB.Save(&product).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Failed to update product: " + err.Error(),
			})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Harga Poin updated successfully",
	})
}
