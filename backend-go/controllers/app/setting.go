package app

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type SettingAppController struct {
	DB *gorm.DB
}

func NewSettingAppController(db *gorm.DB) *SettingAppController {
	return &SettingAppController{DB: db}
}

// GetHargaPoin handles GET /api/settings/harga-poin
func (ctrl *SettingAppController) GetHargaPoin(c *gin.Context) {
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
