package app

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type CartController struct {
	DB *gorm.DB
}

func NewCartController(db *gorm.DB) *CartController {
	return &CartController{DB: db}
}

// AddToCart menambahkan item ke keranjang
func (ctrl *CartController) AddToCart(c *gin.Context) {
	type RequestBody struct {
		UserID    uint   `json:"userId" binding:"required"`
		ProductID string `json:"productId" binding:"required"`
		Quantity  int    `json:"quantity" binding:"required"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	tx := ctrl.DB.Begin()

	// Cek apakah item sudah ada di keranjang
	var existingCartItem models.Cart
	err := tx.Where("user_id = ? AND product_id = ? AND status = ?",
		reqBody.UserID, reqBody.ProductID, "active").
		First(&existingCartItem).Error

	if err == nil {
		// Update jumlah jika item sudah ada
		existingCartItem.Quantity += reqBody.Quantity
		if err := tx.Save(&existingCartItem).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update cart"})
			return
		}
		tx.Commit()
		c.JSON(http.StatusOK, gin.H{
			"message": "Cart updated successfully",
			"cart":    existingCartItem,
		})
		return
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error checking cart"})
		return
	}

	// Tambahkan item baru ke keranjang
	newCartItem := models.Cart{
		UserID:    reqBody.UserID,
		ProductID: reqBody.ProductID,
		Quantity:  reqBody.Quantity,
		Status:    "active",
	}

	if err := tx.Create(&newCartItem).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to add item to cart"})
		return
	}

	tx.Commit()
	c.JSON(http.StatusCreated, gin.H{
		"message": "Item added to cart",
		"cart":    newCartItem,
	})
}

// GetCartByUser mendapatkan keranjang berdasarkan user ID
func (ctrl *CartController) GetCartByUser(c *gin.Context) {
	userID := c.Param("userId")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "User ID is required"})
		return
	}

	// Konversi userID ke uint
	uid, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid user ID"})
		return
	}

	var cartItems []models.Cart
	if err := ctrl.DB.Where("user_id = ? AND status = ?", uid, "active").
		Preload("Product").
		Find(&cartItems).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error retrieving cart"})
		return
	}

	if len(cartItems) == 0 {
		c.JSON(http.StatusOK, gin.H{
			"cart":    []string{},
			"message": "No items in the cart",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"cart": cartItems})
}

// UpdateQuantityInCart mengupdate kuantitas item di keranjang
func (ctrl *CartController) UpdateQuantityInCart(c *gin.Context) {
	type RequestBody struct {
		UserID    uint   `json:"userId" binding:"required"`
		ProductID string `json:"productId" binding:"required"`
		Quantity  int    `json:"quantity" binding:"required"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	if reqBody.Quantity <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Quantity harus lebih besar dari 0"})
		return
	}

	tx := ctrl.DB.Begin()

	// Cek item di keranjang
	var cartItem models.Cart
	if err := tx.Where("user_id = ? AND product_id = ? AND status = ?",
		reqBody.UserID, reqBody.ProductID, "active").
		Preload("Product").
		First(&cartItem).Error; err != nil {
		tx.Rollback()
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"message": "Item not found in cart"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Error retrieving cart item"})
		}
		return
	}

	// Cek stok produk
	if cartItem.Product == nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Product data not found"})
		return
	}

	if reqBody.Quantity > cartItem.Product.Stok {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "Stok produk tidak mencukupi. Stok tersedia: " + strconv.Itoa(cartItem.Product.Stok),
		})
		return
	}

	// Update kuantitas
	cartItem.Quantity = reqBody.Quantity
	if err := tx.Save(&cartItem).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update quantity"})
		return
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{
		"message": "Quantity produk berhasil diperbarui",
		"cart":    cartItem,
	})
}

// GetItemCountInCart mendapatkan jumlah item di keranjang
func (ctrl *CartController) GetItemCountInCart(c *gin.Context) {
	userID := c.Param("userId")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "User ID is required"})
		return
	}

	// Konversi userID ke uint
	uid, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid user ID"})
		return
	}

	var count int64
	if err := ctrl.DB.Model(&models.Cart{}).
		Where("user_id = ? AND status = ?", uid, "active").
		Count(&count).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error retrieving item count"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"itemCount": count})
}

// DeleteCartItem menghapus item dari keranjang
func (ctrl *CartController) DeleteCartItem(c *gin.Context) {
	cartID := c.Param("cartId")
	if cartID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Cart ID is required"})
		return
	}

	type RequestBody struct {
		UserID uint `json:"userId" binding:"required"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	tx := ctrl.DB.Begin()

	// Cari item di keranjang
	var cartItem models.Cart
	if err := tx.Where("id = ? AND user_id = ? AND status = ?",
		cartID, reqBody.UserID, "active").
		First(&cartItem).Error; err != nil {
		tx.Rollback()
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{
				"message": "Cart item not found or does not belong to the user",
			})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Error retrieving cart item"})
		}
		return
	}

	// Hapus item (soft delete dengan mengubah status)
	cartItem.Status = "deleted"
	if err := tx.Save(&cartItem).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to delete cart item"})
		return
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{
		"message": "Cart item deleted successfully",
		"cartId":  cartID,
	})
}
