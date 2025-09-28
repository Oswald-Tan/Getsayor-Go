package app

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type FavoriteController struct {
	DB *gorm.DB
}

func NewFavoriteController(db *gorm.DB) *FavoriteController {
	return &FavoriteController{DB: db}
}

// ToggleFavorite menambah/menghapus favorite
func (ctrl *FavoriteController) ToggleFavorite(c *gin.Context) {
	// Dapatkan userID dari context (setelah middleware auth)
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "User not authenticated"})
		return
	}

	type RequestBody struct {
		ProductID uint `json:"productId" binding:"required"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	tx := ctrl.DB.Begin()

	// Cek apakah favorite sudah ada
	var existingFavorite models.Favorite
	err := tx.Where("user_id = ? AND product_id = ?", userID, reqBody.ProductID).
		First(&existingFavorite).Error

	if err == nil {
		// Jika ada, hapus favorite
		if err := tx.Delete(&existingFavorite).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to remove favorite"})
			return
		}
		tx.Commit()
		c.JSON(http.StatusOK, gin.H{
			"isFavorite": false,
			"message":    "Removed from favorites",
		})
		return
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error checking favorite"})
		return
	}

	// Jika belum ada, tambahkan favorite
	newFavorite := models.Favorite{
		UserID:    userID.(uint),
		ProductID: reqBody.ProductID,
	}

	if err := tx.Create(&newFavorite).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to add favorite"})
		return
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{
		"isFavorite": true,
		"message":    "Added to favorites",
	})
}

// GetUserFavorites mendapatkan semua favorite user
func (ctrl *FavoriteController) GetUserFavorites(c *gin.Context) {
	// Dapatkan userID dari context
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "User not authenticated"})
		return
	}

	var favorites []models.Favorite
	if err := ctrl.DB.Where("user_id = ?", userID).
		Preload("Product.ProductItems"). // Preload ProductItems
		Find(&favorites).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error retrieving favorites"})
		return
	}

	// Transform ke format response yang sama dengan get produk
	favoriteProducts := make([]gin.H, 0, len(favorites))
	for _, fav := range favorites {
		if fav.Product == nil {
			continue
		}

		// Siapkan array untuk product items
		productItems := make([]gin.H, 0, len(fav.Product.ProductItems))
		for _, item := range fav.Product.ProductItems {
			productItems = append(productItems, gin.H{
				"ID":        item.ID,
				"ProductID": item.ProductID,
				"Stok":      item.Stok,
				"HargaPoin": item.HargaPoin,
				"HargaRp":   item.HargaRp,
				"Jumlah":    item.Jumlah,
				"Satuan":    item.Satuan,
				"CreatedAt": item.CreatedAt,
				"UpdatedAt": item.UpdatedAt,
			})
		}

		product := gin.H{
			"ID":           fav.Product.ID,
			"NameProduk":   fav.Product.NameProduk,
			"Deskripsi":    fav.Product.Deskripsi,
			"Kategori":     fav.Product.Kategori,
			"Image":        fav.Product.Image,
			"CreatedAt":    fav.Product.CreatedAt,
			"UpdatedAt":    fav.Product.UpdatedAt,
			"IsFavorite":   true,
			"ProductItems": productItems, // Array of items
		}
		favoriteProducts = append(favoriteProducts, product)
	}

	c.JSON(http.StatusOK, favoriteProducts)
}

// CheckFavorite mengecek status favorite
func (ctrl *FavoriteController) CheckFavorite(c *gin.Context) {
	// Dapatkan userID dari context
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "User not authenticated"})
		return
	}

	productID := c.Param("productId")
	if productID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Product ID is required"})
		return
	}

	// Konversi productID ke uint
	pid, err := strconv.ParseUint(productID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid product ID"})
		return
	}

	var favorite models.Favorite
	if err := ctrl.DB.Where("user_id = ? AND product_id = ?", userID, pid).
		First(&favorite).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusOK, gin.H{"isFavorite": false})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error checking favorite"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"isFavorite": true})
}
