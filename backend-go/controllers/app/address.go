package app

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type AddressController struct {
	DB *gorm.DB
}

func NewAddressController(db *gorm.DB) *AddressController {
	return &AddressController{DB: db}
}

// CreateAddress membuat alamat baru
func (ctrl *AddressController) CreateAddress(c *gin.Context) {
	type RequestBody struct {
		UserID        uint   `json:"user_id" binding:"required"`
		RecipientName string `json:"recipient_name" binding:"required"`
		PhoneNumber   string `json:"phone_number" binding:"required"`
		AddressLine1  string `json:"address_line_1" binding:"required"`
		City          string `json:"city"`
		State         string `json:"state"`
		PostalCode    string `json:"postal_code"`
		IsDefault     bool   `json:"isDefault"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	db := c.MustGet("db").(*gorm.DB)
	tx := db.Begin()

	// Cek apakah user sudah memiliki alamat default
	var existingDefaultAddress models.Address
	if err := tx.Where("user_id = ? AND is_default = ?", reqBody.UserID, true).First(&existingDefaultAddress).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			// Jika tidak ada alamat default, atur alamat pertama sebagai default
			reqBody.IsDefault = true
		} else {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Error checking default address"})
			return
		}
	}

	// Jika isDefault true, update alamat lama menjadi is_default: false
	if reqBody.IsDefault {
		if err := tx.Model(&models.Address{}).Where("user_id = ? AND is_default = ?", reqBody.UserID, true).Update("is_default", false).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update existing addresses"})
			return
		}
	}

	// Buat alamat baru
	newAddress := models.Address{
		UserID:        reqBody.UserID,
		RecipientName: reqBody.RecipientName,
		PhoneNumber:   reqBody.PhoneNumber,
		AddressLine1:  reqBody.AddressLine1,
		City:          reqBody.City,
		State:         reqBody.State,
		PostalCode:    reqBody.PostalCode,
		IsDefault:     reqBody.IsDefault,
	}

	if err := tx.Create(&newAddress).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error creating address"})
		return
	}

	tx.Commit()
	c.JSON(http.StatusCreated, gin.H{
		"message": "Address created successfully",
		"data":    newAddress,
	})
}

// UpdateAddress mengupdate alamat berdasarkan ID
func (ctrl *AddressController) UpdateAddress(c *gin.Context) {
	id := c.Param("id")

	type RequestBody struct {
		UserID        uint   `json:"user_id" binding:"required"`
		RecipientName string `json:"recipient_name"`
		PhoneNumber   string `json:"phone_number"`
		AddressLine1  string `json:"address_line_1"`
		City          string `json:"city"`
		State         string `json:"state"`
		PostalCode    string `json:"postal_code"`
		IsDefault     bool   `json:"isDefault"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	db := c.MustGet("db").(*gorm.DB)
	tx := db.Begin()

	// Cari alamat berdasarkan ID
	var address models.Address
	if err := tx.First(&address, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Address not found"})
		return
	}

	// Pastikan user_id yang mengirimkan request adalah pemilik alamat
	if address.UserID != reqBody.UserID {
		c.JSON(http.StatusForbidden, gin.H{"message": "You are not authorized to update this address"})
		return
	}

	// Jika isDefault true dan alamat ini bukan default, ubah alamat lain menjadi non-default
	if reqBody.IsDefault && !address.IsDefault {
		if err := tx.Model(&models.Address{}).Where("user_id = ? AND is_default = ?", reqBody.UserID, true).Update("is_default", false).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update existing addresses"})
			return
		}
	}

	// Perbarui alamat
	address.RecipientName = reqBody.RecipientName
	address.PhoneNumber = reqBody.PhoneNumber
	address.AddressLine1 = reqBody.AddressLine1
	address.City = reqBody.City
	address.State = reqBody.State
	address.PostalCode = reqBody.PostalCode
	address.IsDefault = reqBody.IsDefault

	if err := tx.Save(&address).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error updating address"})
		return
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{
		"message": "Address updated successfully",
		"data":    address,
	})
}

// GetAddressByID mendapatkan alamat berdasarkan ID
func (ctrl *AddressController) GetAddressByID(c *gin.Context) {
	id := c.Param("id")

	db := c.MustGet("db").(*gorm.DB)

	var address models.Address
	if err := db.First(&address, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Address not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Address retrieved successfully",
		"data":    address,
	})
}

// GetUserAddresses mendapatkan semua alamat milik user tertentu
func (ctrl *AddressController) GetUserAddresses(c *gin.Context) {
	userID := c.Param("user_id")

	db := c.MustGet("db").(*gorm.DB)

	var addresses []models.Address
	if err := db.Where("user_id = ?", userID).Find(&addresses).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error retrieving addresses"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Addresses retrieved successfully",
		"data":    addresses,
	})
}

// GetDefaultAddress mendapatkan alamat default untuk user tertentu
func (ctrl *AddressController) GetDefaultAddress(c *gin.Context) {
	userID := c.Param("user_id")

	db := c.MustGet("db").(*gorm.DB)

	// Step 1: Get default address
	var defaultAddress models.Address
	if err := db.Where("user_id = ? AND is_default = ?", userID, true).First(&defaultAddress).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"message": "Default address not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "Error retrieving default address",
			"error":   err.Error(),
		})
		return
	}

	// Step 2: Find city by name
	var city models.City
	if err := db.Where("name = ?", defaultAddress.City).First(&city).Error; err != nil {
		// City not found - return address without shipping rate
		c.JSON(http.StatusOK, gin.H{
			"message":        "Default address retrieved successfully",
			"defaultAddress": defaultAddress,
			"shippingRate":   nil,
		})
		return
	}

	// Step 3: Find shipping rate by city ID
	var shippingRate models.ShippingRate
	if err := db.Preload("City").Where("city_id = ?", city.ID).First(&shippingRate).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			// Shipping rate not found - return address without shipping rate
			c.JSON(http.StatusOK, gin.H{
				"message":        "Default address retrieved successfully",
				"defaultAddress": defaultAddress,
				"shippingRate":   nil,
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": "Error retrieving shipping rate",
			"error":   err.Error(),
		})
		return
	}

	// Step 4: Return successful response with all data
	c.JSON(http.StatusOK, gin.H{
		"message":        "Default address retrieved successfully",
		"defaultAddress": defaultAddress,
		"shippingRate": gin.H{
			"id":     shippingRate.ID,
			"cityId": shippingRate.CityID,
			"price":  shippingRate.Price,
			"city": gin.H{
				"id":   shippingRate.City.ID,
				"name": shippingRate.City.Name,
			},
		},
	})
}

// DeleteAddress menghapus alamat berdasarkan ID
func (ctrl *AddressController) DeleteAddress(c *gin.Context) {
	id := c.Param("id")

	db := c.MustGet("db").(*gorm.DB)

	var address models.Address
	if err := db.First(&address, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Address not found"})
		return
	}

	// Jika alamat adalah alamat default, maka tidak bisa dihapus
	if address.IsDefault {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "Default address cannot be deleted. Please update the default address first.",
		})
		return
	}

	if err := db.Delete(&address).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error deleting address"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Address deleted successfully"})
}
