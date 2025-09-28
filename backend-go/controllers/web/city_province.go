package web

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type CityProvinceController struct {
	DB *gorm.DB
}

func NewCityProvinceController(db *gorm.DB) *CityProvinceController {
	return &CityProvinceController{DB: db}
}

// GetProvinceAndCity handles GET /provinces
func (ctrl *CityProvinceController) GetProvinceAndCity(c *gin.Context) {
	var provinces []models.Province

	if err := ctrl.DB.Preload("Cities").Find(&provinces).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error fetching provinces",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": provinces})
}

// GetCity handles GET /provinces/cities
func (ctrl *CityProvinceController) GetCity(c *gin.Context) {
	var cities []models.City

	if err := ctrl.DB.Preload("Province").Find(&cities).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error fetching cities",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": cities})
}

type CreateRequest struct {
	ProvinceName string   `json:"provinceName" binding:"required"`
	Cities       []string `json:"cities" binding:"required"`
}

// CreateProvinceAndCity handles POST /provinces
func (ctrl *CityProvinceController) CreateProvinceAndCity(c *gin.Context) {
	var req CreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": err.Error()})
		return
	}

	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	province := models.Province{Name: req.ProvinceName}
	if err := tx.Create(&province).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error creating province",
			"error":   err.Error(),
		})
		return
	}

	for _, cityName := range req.Cities {
		city := models.City{
			Name:       cityName,
			ProvinceID: province.ID,
		}
		if err := tx.Create(&city).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Error creating city",
				"error":   err.Error(),
			})
			return
		}
	}

	tx.Commit()
	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "Province and cities created successfully",
	})
}

// DeleteProvinceAndCities handles DELETE /provinces/:id
func (ctrl *CityProvinceController) DeleteProvinceAndCities(c *gin.Context) {
	id := c.Param("id")

	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 1. Hapus shipping_rates terkait kota di provinsi ini
	if err := tx.Exec(`
        DELETE FROM shipping_rates 
        WHERE city_id IN (
            SELECT id FROM cities WHERE province_id = ?
        )
    `, id).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error deleting shipping rates",
			"error":   err.Error(),
		})
		return
	}

	// 2. Hapus cities
	if err := tx.Where("province_id = ?", id).Delete(&models.City{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error deleting cities",
			"error":   err.Error(),
		})
		return
	}

	// 3. Hapus province
	if err := tx.Where("id = ?", id).Delete(&models.Province{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error deleting province",
			"error":   err.Error(),
		})
		return
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Province and cities deleted successfully",
	})
}
