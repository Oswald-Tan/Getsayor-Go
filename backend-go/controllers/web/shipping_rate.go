package web

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type ShippingRateController struct {
	DB *gorm.DB
}

func NewShippingRateController(db *gorm.DB) *ShippingRateController {
	return &ShippingRateController{DB: db}
}

// GetAllShippingRates handles GET /shipping-rates
func (ctrl *ShippingRateController) GetAllShippingRates(c *gin.Context) {
	var shippingRates []models.ShippingRate

	if err := ctrl.DB.Preload("City").Find(&shippingRates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error fetching shipping rates",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    shippingRates,
	})
}

// GetShippingRateById handles GET /shipping-rates/:id
func (ctrl *ShippingRateController) GetShippingRateById(c *gin.Context) {
	id := c.Param("id")
	var shippingRate models.ShippingRate

	if err := ctrl.DB.Preload("City").First(&shippingRate, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Shipping rate not found",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    shippingRate,
	})
}

// GetShippingRateByCity handles GET /shipping-rates/city/:cityId
func (ctrl *ShippingRateController) GetShippingRateByCity(c *gin.Context) {
	cityId := c.Param("cityId")
	var shippingRate models.ShippingRate

	if err := ctrl.DB.
		Preload("City").
		Where("city_id = ?", cityId).
		First(&shippingRate).Error; err != nil {

		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Shipping rate not found for this city",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    shippingRate,
	})
}

type CreateShippingRateRequest struct {
	CityID uint    `json:"cityId" binding:"required"`
	Price  float64 `json:"price" binding:"required"`
}

// CreateShippingRate handles POST /shipping-rates
func (ctrl *ShippingRateController) CreateShippingRate(c *gin.Context) {
	var req CreateShippingRateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	// Check if city exists
	var city models.City
	if err := ctrl.DB.First(&city, req.CityID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "City not found",
		})
		return
	}

	// Check if shipping rate already exists for this city
	var existingRate models.ShippingRate
	if err := ctrl.DB.Where("city_id = ?", req.CityID).First(&existingRate).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{
			"success": false,
			"message": "Shipping rate already exists for this city", // Pesan spesifik
		})
		return
	}

	// Create new shipping rate
	shippingRate := models.ShippingRate{
		CityID: req.CityID,
		Price:  req.Price,
	}

	if err := ctrl.DB.Create(&shippingRate).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error creating shipping rate",
			"error":   err.Error(),
		})
		return
	}

	// Reload with city data
	ctrl.DB.Preload("City").First(&shippingRate, shippingRate.ID)

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "Shipping rate created successfully",
		"data":    shippingRate,
	})
}

type UpdateShippingRateRequest struct {
	Price float64 `json:"Price" binding:"required,min=0"`
}

// UpdateShippingRate handles PUT /shipping-rates/:id
func (ctrl *ShippingRateController) UpdateShippingRate(c *gin.Context) {
	id := c.Param("id")
	var req UpdateShippingRateRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	var shippingRate models.ShippingRate
	if err := ctrl.DB.First(&shippingRate, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Shipping rate not found",
		})
		return
	}

	// Update price
	shippingRate.Price = req.Price

	if err := ctrl.DB.Save(&shippingRate).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error updating shipping rate",
			"error":   err.Error(),
		})
		return
	}

	// Reload with city data
	ctrl.DB.Preload("City").First(&shippingRate, shippingRate.ID)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Shipping rate updated successfully",
		"data":    shippingRate,
	})
}

// DeleteShippingRate handles DELETE /shipping-rates/:id
func (ctrl *ShippingRateController) DeleteShippingRate(c *gin.Context) {
	id := c.Param("id")

	var shippingRate models.ShippingRate
	if err := ctrl.DB.First(&shippingRate, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Shipping rate not found",
		})
		return
	}

	if err := ctrl.DB.Delete(&shippingRate).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error deleting shipping rate",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Shipping rate deleted successfully",
	})
}
