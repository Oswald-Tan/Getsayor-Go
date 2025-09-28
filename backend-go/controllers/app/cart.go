package app

import (
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"time"

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
		UserID        uint `json:"userId" form:"userId" binding:"required"`
		ProductItemID uint `json:"productItemId" form:"productItemId" binding:"required"`
		Quantity      int  `json:"quantity" form:"quantity" binding:"required"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		fmt.Printf("Binding error: %v\n", err)
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	fmt.Printf("Request body: %+v\n", reqBody)

	tx := ctrl.DB.Begin()

	// Check stock availability
	var productItem models.ProductItem
	if err := tx.First(&productItem, reqBody.ProductItemID).Error; err != nil {
		tx.Rollback()
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"message": "Product variant not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Error checking product stock"})
		}
		return
	}

	if productItem.Stok < reqBody.Quantity {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"message": "Insufficient stock"})
		return
	}

	// Check if item already exists in cart
	var existingCartItem models.Cart
	err := tx.Where("user_id = ? AND product_item_id = ? AND status = ?",
		reqBody.UserID, reqBody.ProductItemID, "active").First(&existingCartItem).Error

	if err == nil {
		// Update quantity if item exists
		newQuantity := existingCartItem.Quantity + reqBody.Quantity

		// Check updated quantity against stock
		if productItem.Stok < newQuantity {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{"message": "Exceeds available stock"})
			return
		}

		existingCartItem.Quantity = newQuantity
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

	// Add new item to cart
	newCartItem := models.Cart{
		UserID:        reqBody.UserID,
		ProductItemID: reqBody.ProductItemID,
		Quantity:      reqBody.Quantity,
		Status:        "active",
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

	uid, err := strconv.ParseUint(userID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid user ID"})
		return
	}

	var cartItems []models.Cart
	if err := ctrl.DB.
		Where("user_id = ? AND status = ?", uint(uid), "active").
		Preload("ProductItem").
		Preload("ProductItem.Product").
		Find(&cartItems).Error; err != nil {

		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error retrieving cart"})
		return
	}

	// Handle empty cart
	if len(cartItems) == 0 {
		c.JSON(http.StatusOK, gin.H{
			"cart":    []string{},
			"message": "No items in the cart",
		})
		return
	}

	// Mapping untuk response yang diinginkan Flutter
	type CartResponse struct {
		ID            uint      `json:"ID"`
		UserID        uint      `json:"UserID"`
		ProductItemID uint      `json:"ProductItemID"`
		Quantity      int       `json:"Quantity"`
		Notes         string    `json:"Notes"`
		Status        string    `json:"Status"`
		CreatedAt     time.Time `json:"CreatedAt"`
		UpdatedAt     time.Time `json:"UpdatedAt"`
		ProductItem   struct {
			ID         uint      `json:"ID"`
			ProductID  uint      `json:"ProductID"`
			Stok       int       `json:"Stok"`
			HargaPoin  int       `json:"HargaPoin"`
			HargaRp    int       `json:"HargaRp"`
			Jumlah     int       `json:"Jumlah"`
			Satuan     string    `json:"Satuan"`
			CreatedAt  time.Time `json:"CreatedAt"`
			UpdatedAt  time.Time `json:"UpdatedAt"`
			NameProduk string    `json:"NameProduk"`
			Image      string    `json:"Image"`
		} `json:"product_item"`
	}

	var response []CartResponse

	for _, item := range cartItems {
		cr := CartResponse{
			ID:            item.ID,
			UserID:        item.UserID,
			ProductItemID: item.ProductItemID,
			Quantity:      item.Quantity,
			Notes:         item.Notes,
			Status:        item.Status,
			CreatedAt:     item.CreatedAt,
			UpdatedAt:     item.UpdatedAt,
		}

		if item.ProductItem != nil {
			cr.ProductItem.ID = item.ProductItem.ID
			cr.ProductItem.ProductID = item.ProductItem.ProductID
			cr.ProductItem.Stok = item.ProductItem.Stok
			cr.ProductItem.HargaPoin = item.ProductItem.HargaPoin
			cr.ProductItem.HargaRp = item.ProductItem.HargaRp
			cr.ProductItem.Jumlah = item.ProductItem.Jumlah
			cr.ProductItem.Satuan = item.ProductItem.Satuan
			cr.ProductItem.CreatedAt = item.ProductItem.CreatedAt
			cr.ProductItem.UpdatedAt = item.ProductItem.UpdatedAt

			// Ambil data dari relasi Product
			if item.ProductItem.Product != nil {
				cr.ProductItem.NameProduk = item.ProductItem.Product.NameProduk
				cr.ProductItem.Image = item.ProductItem.Product.Image
			} else {
				cr.ProductItem.NameProduk = "Unknown Product"
				cr.ProductItem.Image = ""
			}
		}

		response = append(response, cr)
	}

	c.JSON(http.StatusOK, gin.H{"cart": response})
}

// UpdateQuantityInCart mengupdate kuantitas item di keranjang
func (ctrl *CartController) UpdateQuantityInCart(c *gin.Context) {
	type RequestBody struct {
		UserID        uint `json:"userId" binding:"required"`        // Ubah menjadi uint
		ProductItemID uint `json:"productItemId" binding:"required"` // Gunakan productItemId
		Quantity      int  `json:"quantity" binding:"required"`
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

	// Cari item cart berdasarkan productItemID
	var cartItem models.Cart
	if err := tx.Where("user_id = ? AND product_item_id = ? AND status = ?",
		reqBody.UserID, reqBody.ProductItemID, "active").
		Preload("ProductItem"). // Preload ProductItem saja
		First(&cartItem).Error; err != nil {
		tx.Rollback()
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"message": "Item not found in cart"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Error retrieving cart item"})
		}
		return
	}

	// Cek ketersediaan stok langsung dari ProductItem
	if cartItem.ProductItem == nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Product item data not found"})
		return
	}

	if reqBody.Quantity > cartItem.ProductItem.Stok {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "Stok produk tidak mencukupi. Stok tersedia: " + strconv.Itoa(cartItem.ProductItem.Stok),
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
