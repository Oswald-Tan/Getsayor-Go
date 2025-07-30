package web

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type PoinController struct {
	DB *gorm.DB
}

func NewPoinController(db *gorm.DB) *PoinController {
	return &PoinController{DB: db}
}

// GetPoins handles GET /poins
func (ctrl *PoinController) GetPoins(c *gin.Context) {
	var poins []models.Poin

	if err := ctrl.DB.Preload("Discount").Order("poin asc").Find(&poins).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error fetching poins",
			"error":   err.Error(),
		})
		return
	}

	// Pastikan mengembalikan array meskipun kosong
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    poins, // Ini harus berupa array
	})
}

// GetPoinById handles GET /poins/:id
func (ctrl *PoinController) GetPoinById(c *gin.Context) {
	id := c.Param("id")
	var poin models.Poin

	if err := ctrl.DB.Preload("Discount").First(&poin, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Poin not found",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": poin})
}

// CreatePoin handles POST /poins
func (ctrl *PoinController) CreatePoin(c *gin.Context) {
	type CreateRequest struct {
		Poin int `json:"poin" binding:"required"`
	}

	var req CreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": err.Error()})
		return
	}

	// Check if poin value already exists
	var existingPoin models.Poin
	if err := ctrl.DB.Where("poin = ?", req.Poin).First(&existingPoin).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Poin value already exists",
		})
		return
	}

	// Generate productId
	productId := fmt.Sprintf("points_%d", req.Poin)

	newPoin := models.Poin{
		Poin:      req.Poin,
		ProductID: productId,
	}

	if err := ctrl.DB.Create(&newPoin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error creating poin",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "Poin created successfully",
	})
}

// UpdatePoin handles PATCH /poins/:id
func (ctrl *PoinController) UpdatePoin(c *gin.Context) {
	id := c.Param("id")

	type UpdateRequest struct {
		DiscountPercentage *float64 `json:"discountPercentage"`
	}

	var req UpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": err.Error()})
		return
	}

	// Validate discount percentage
	if req.DiscountPercentage != nil && (*req.DiscountPercentage < 0 || *req.DiscountPercentage > 100) {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Discount percentage must be between 0 and 100",
		})
		return
	}

	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Get existing poin
	var poin models.Poin
	if err := tx.Preload("Discount").First(&poin, id).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Poin not found",
		})
		return
	}

	// Update discount
	if req.DiscountPercentage != nil {
		// Generate promoProductId if discount > 0
		var promoProductId string
		if *req.DiscountPercentage > 0 {
			promoProductId = fmt.Sprintf("points_%.0f_%d", *req.DiscountPercentage, poin.Poin)

			// Check for unique promoProductId
			var existing models.Poin
			if err := tx.Where("promo_product_id = ? AND id != ?", promoProductId, id).First(&existing).Error; err == nil {
				tx.Rollback()
				c.JSON(http.StatusBadRequest, gin.H{
					"success": false,
					"message": "Promo product ID already exists",
				})
				return
			}
		}

		// Update poin
		poin.PromoProductID = promoProductId
		if err := tx.Save(&poin).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Error updating poin",
				"error":   err.Error(),
			})
			return
		}

		// Update or create discount
		if poin.Discount != nil {
			poin.Discount.Percentage = *req.DiscountPercentage
			if err := tx.Save(&poin.Discount).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{
					"success": false,
					"message": "Error updating discount",
					"error":   err.Error(),
				})
				return
			}
		} else {
			discount := models.Discount{
				Percentage: *req.DiscountPercentage,
				PoinID:     poin.ID,
			}
			if err := tx.Create(&discount).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{
					"success": false,
					"message": "Error creating discount",
					"error":   err.Error(),
				})
				return
			}
		}
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Poin updated successfully",
	})
}

// UpdateDiscount handles POST /poins/update-discount
func (ctrl *PoinController) UpdateDiscount(c *gin.Context) {
	type UpdateRequest struct {
		ID                 uint    `json:"id" binding:"required"`
		DiscountPercentage float64 `json:"discountPercentage" binding:"required"`
	}

	var req UpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": err.Error()})
		return
	}

	// Validate discount percentage
	if req.DiscountPercentage < 0 || req.DiscountPercentage > 100 {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Discount percentage must be between 0 and 100",
		})
		return
	}

	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Get existing poin
	var poin models.Poin
	if err := tx.Preload("Discount").First(&poin, req.ID).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Poin not found",
		})
		return
	}

	// Update or create discount
	if poin.Discount != nil {
		poin.Discount.Percentage = req.DiscountPercentage
		if err := tx.Save(&poin.Discount).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Error updating discount",
				"error":   err.Error(),
			})
			return
		}
	} else {
		discount := models.Discount{
			Percentage: req.DiscountPercentage,
			PoinID:     poin.ID,
		}
		if err := tx.Create(&discount).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Error creating discount",
				"error":   err.Error(),
			})
			return
		}
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Discount updated successfully",
	})
}

// DeletePoin handles DELETE /poins/:id
func (ctrl *PoinController) DeletePoin(c *gin.Context) {
	id := c.Param("id")

	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Check if poin exists
	var poin models.Poin
	if err := tx.Preload("Discount").First(&poin, id).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Poin not found",
		})
		return
	}

	// Delete associated discount if exists
	if poin.Discount != nil {
		if err := tx.Delete(&poin.Discount).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Error deleting discount",
				"error":   err.Error(),
			})
			return
		}
	}

	// Delete poin
	if err := tx.Delete(&poin).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error deleting poin",
			"error":   err.Error(),
		})
		return
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Poin deleted successfully",
	})
}
