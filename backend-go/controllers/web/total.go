package web

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type TotalController struct {
	DB *gorm.DB
}

func NewTotalController(db *gorm.DB) *TotalController {
	return &TotalController{DB: db}
}

// GetTotalPesananPending handles GET /count/pesanan-pending
func (ctrl *TotalController) GetTotalPesananPending(c *gin.Context) {
	var total int64
	result := ctrl.DB.Model(&models.Pesanan{}).
		Where("status = ?", "pending").
		Count(&total)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error fetching pending orders",
			"error":   result.Error.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":             true,
		"totalPesananPending": total,
	})
}

func (ctrl *TotalController) GetTotalUserApproveFalse(c *gin.Context) {
	var total int64
	result := ctrl.DB.Model(&models.User{}).
		Where("is_approved = ? AND role_id = ?", false, 2).
		Count(&total)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error fetching unapproved users",
			"error":   result.Error.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":               true,
		"totalUserApproveFalse": total,
	})
}

func (ctrl *TotalController) GetTotalProduk(c *gin.Context) {
	var total int64
	result := ctrl.DB.Model(&models.Product{}).Count(&total)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error fetching products count",
			"error":   result.Error.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":     true,
		"totalProduk": total,
	})
}
