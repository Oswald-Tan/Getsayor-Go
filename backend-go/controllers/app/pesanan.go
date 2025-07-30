package app

import (
	"errors"
	"fmt"
	"log"
	"math"
	"net/http"
	"strconv"
	"strings"
	"time"

	"backend-go/models"
	"backend-go/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type OrderController struct {
	DB *gorm.DB
}

func NewOrderController(db *gorm.DB) *OrderController {
	return &OrderController{DB: db}
}

// GetPesanan handles GET /orders
func (ctrl *OrderController) GetPesanan(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	search := c.Query("search")
	status := c.Query("status")
	offset := page * limit

	// Build where condition
	where := make(map[string]interface{})
	if status != "" && status != "all" {
		where["status"] = status
	}

	// Count total orders
	var totalRows int64
	query := ctrl.DB.Model(&models.Pesanan{}).Where(where)
	if search != "" {
		query = query.Joins("JOIN order_items ON order_items.pesanan_id = pesanans.id").
			Where("order_items.nama_produk LIKE ?", "%"+search+"%")
	}
	query.Count(&totalRows)

	totalPage := (int(totalRows) + limit - 1) / limit // Ceil division

	// Get orders
	var pesanans []models.Pesanan
	query = ctrl.DB.Preload("User", func(db *gorm.DB) *gorm.DB {
		return db.Preload("UserDetails").Preload("Addresses", "is_default = ?", true)
	}).Preload("OrderItems.Produk").Where(where)

	if search != "" {
		query = query.Joins("JOIN order_items ON order_items.pesanan_id = pesanans.id").
			Where("order_items.nama_produk LIKE ?", "%"+search+"%")
	}

	err := query.Order("pesanans.created_at DESC").
		Offset(offset).Limit(limit).Find(&pesanans).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data":      pesanans,
		"page":      page,
		"limit":     limit,
		"totalPage": totalPage,
		"totalRows": totalRows,
	})
}

// GetPesananByID handles GET /orders/:id
func (ctrl *OrderController) GetPesananByID(c *gin.Context) {
	id := c.Param("id")

	var pesanan models.Pesanan
	err := ctrl.DB.Where("id = ?", id).First(&pesanan).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"message": "Order not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, pesanan)
}

// GetPesananByUser handles GET /orders/user/:userId
func (ctrl *OrderController) GetPesananByUser(c *gin.Context) {
	userID := c.Param("userId")

	var pesanans []models.Pesanan
	err := ctrl.DB.Preload("OrderItems.Product").
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Find(&pesanans).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Orders retrieved successfully",
		"data":    pesanans,
	})
}

// GetPesananByUserDelivered handles GET /orders/user-delivered/:userId
func (ctrl *OrderController) GetPesananByUserDelivered(c *gin.Context) {
	userID := c.Param("userId")

	var pesanans []models.Pesanan
	err := ctrl.DB.Preload("OrderItems.Produk").
		Where("user_id = ? AND status = ?", userID, "delivered").
		Order("created_at DESC").
		Find(&pesanans).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Delivered orders retrieved successfully",
		"data":    pesanans,
	})
}

// CheckOrder handles GET /orders/check
func (ctrl *OrderController) CheckOrder(c *gin.Context) {
	idempotencyKey := c.Query("idempotencyKey")
	if idempotencyKey == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "idempotencyKey is required"})
		return
	}

	var pesanan models.Pesanan
	err := ctrl.DB.Preload("OrderItems.Produk").
		Preload("User.UserDetails").
		Where("idempotency_key = ?", idempotencyKey).
		First(&pesanan).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"message": "Order not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, pesanan)
}

// BuatPesananCOD handles POST /orders/cod
func (ctrl *OrderController) BuatPesananCOD(c *gin.Context) {
	var req struct {
		UserID           uint    `json:"userId" binding:"required"`
		IdempotencyKey   string  `json:"idempotencyKey" binding:"required"`
		MetodePembayaran string  `json:"metodePembayaran" binding:"required"`
		HargaRp          float64 `json:"hargaRp"`
		Ongkir           float64 `json:"ongkir"`
		TotalBayar       float64 `json:"totalBayar" binding:"required"`
		InvoiceNumber    string  `json:"invoiceNumber"`
		Items            []struct {
			ProductID  uint    `json:"productId" binding:"required"`
			NamaProduk string  `json:"namaProduk" binding:"required"`
			Harga      float64 `json:"harga" binding:"required"`
			Jumlah     int     `json:"jumlah" binding:"required"`
			Berat      float64 `json:"berat"`
			Satuan     string  `json:"satuan"`
			TotalHarga float64 `json:"totalHarga" binding:"required"`
		} `json:"items" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		log.Printf("Bad request: %v", req) // LOG REQUEST
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "Invalid request format",
			"details": err.Error(),
		})
		return
	}
	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Check idempotency key
	var existingOrder models.Pesanan
	if err := tx.Where("idempotency_key = ?", req.IdempotencyKey).First(&existingOrder).Error; err == nil {
		tx.Commit()
		c.JSON(http.StatusOK, existingOrder)
		return
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error checking idempotency key"})
		return
	}

	// Validate items
	if len(req.Items) == 0 {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"message": "Items are required"})
		return
	}

	// Check user
	var user models.User
	if err := tx.Preload("Details").First(&user, req.UserID).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		return
	}

	// Generate order ID
	uniqueID := strings.ToUpper(strings.Replace(uuid.New().String(), "-", "", -1)[:8])
	orderID := "GS" + uniqueID

	// Create order
	pesanan := models.Pesanan{
		UserId:           req.UserID,
		OrderId:          orderID,
		IdempotencyKey:   req.IdempotencyKey,
		MetodePembayaran: req.MetodePembayaran,
		HargaRp:          int(math.Round(req.HargaRp)),
		Ongkir:           int(math.Round(req.Ongkir)),
		TotalBayar:       int(math.Round(req.TotalBayar)),
		PaymentStatus:    "unpaid",
		Status:           "pending",
		InvoiceNumber:    req.InvoiceNumber,
	}

	if err := tx.Create(&pesanan).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create order"})
		return
	}

	// Create order items and update stock
	for _, item := range req.Items {
		// Create order item
		orderItem := models.OrderItem{
			PesananID:  pesanan.ID,
			ProductID:  item.ProductID,
			NamaProduk: item.NamaProduk,
			Harga:      int(math.Round(item.Harga)),
			Jumlah:     item.Jumlah,
			Berat:      int(math.Round(item.Berat)),
			Satuan:     item.Satuan,
			TotalHarga: int(math.Round(item.TotalHarga)),
		}

		if err := tx.Create(&orderItem).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create order item"})
			return
		}

		// Update product stock
		var product models.Product
		if err := tx.First(&product, item.ProductID).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusNotFound, gin.H{"message": fmt.Sprintf("Product %d not found", item.ProductID)})
			return
		}

		if product.Stok < item.Jumlah {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{
				"message": fmt.Sprintf("Insufficient stock for %s. Available: %d", product.NameProduk, product.Stok),
			})
			return
		}

		product.Stok -= item.Jumlah
		if err := tx.Save(&product).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update product stock"})
			return
		}
	}

	// Handle affiliate bonus
	if req.TotalBayar >= 200000 {
		currentUser := user
		bonusLevel := 1
		maxBonusBase := 200000.0

		for bonusLevel <= 2 {
			if currentUser.ReferredBy == nil {
				break
			}

			bonusPercentage := 0.0
			switch bonusLevel {
			case 1:
				bonusPercentage = 0.1
			case 2:
				bonusPercentage = 0.05
			}

			BonusAmount := maxBonusBase * bonusPercentage

			bonus := models.AfiliasiBonus{
				UserId:          *currentUser.ReferredBy,
				ReferralUserId:  req.UserID,
				PesananId:       pesanan.ID,
				BonusAmount:     BonusAmount,
				BonusLevel:      bonusLevel,
				ExpiryDate:      time.Now().AddDate(0, 1, 0),
				BonusReceivedAt: time.Now(),
			}

			if err := tx.Create(&bonus).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create affiliate bonus"})
				return
			}

			// Move to next level
			if err := tx.First(&currentUser, *currentUser.ReferredBy).Error; err != nil {
				break
			}
			bonusLevel++
		}
	}

	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Transaction commit failed"})
		return
	}

	// Send notifications
	if user.FCMToken != "" {
		isValid := utils.IsFcmTokenValid(user.FCMToken)
		if isValid {
			firstName := "Pelanggan"
			if user.Details != nil && user.Details.Fullname != "" {
				nameParts := strings.Split(user.Details.Fullname, " ")
				if len(nameParts) > 0 {
					firstName = strings.Title(strings.ToLower(nameParts[0]))
				}
			}

			utils.SendOrderCODNotification(
				user.FCMToken,
				pesanan.OrderId,
				pesanan.TotalBayar,
				firstName,
			)
		} else {
			// Logging tambahan untuk debug
			log.Printf("Invalid FCM token for user ID: %d", user.ID)
			ctrl.DB.Model(&models.User{}).Where("id = ?", req.UserID).Update("fcm_token", nil)
		}
	}

	// Telegram notification - dengan format baru
	var fullPesanan models.Pesanan
	if err := ctrl.DB.
		Preload("User.Details").
		Preload("OrderItems").
		First(&fullPesanan, pesanan.ID).Error; err == nil {

		telegramMsg := utils.FormatTelegramOrderRpMessage(fullPesanan)
		utils.SendTelegramNotification(telegramMsg)
	} else {
		log.Printf("Gagal memuat data pesanan untuk notifikasi: %v", err)
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Order created successfully",
		"data":    pesanan,
	})
}

// BuatPesananCODCart - Membuat pesanan COD dari keranjang
func (ctrl *OrderController) BuatPesananCODCart(c *gin.Context) {
	var req struct {
		UserID           uint    `json:"userId" binding:"required"`
		IdempotencyKey   string  `json:"idempotencyKey" binding:"required"`
		MetodePembayaran string  `json:"metodePembayaran" binding:"required"`
		HargaRp          float64 `json:"hargaRp"`
		Ongkir           float64 `json:"ongkir"`
		TotalBayar       float64 `json:"totalBayar" binding:"required"`
		InvoiceNumber    string  `json:"invoiceNumber"`
		Items            []struct {
			ProductID  uint    `json:"productId" binding:"required"`
			NamaProduk string  `json:"namaProduk" binding:"required"`
			Harga      float64 `json:"harga" binding:"required"`
			Jumlah     int     `json:"jumlah" binding:"required"`
			Berat      float64 `json:"berat"`
			Satuan     string  `json:"satuan"`
			TotalHarga float64 `json:"totalHarga" binding:"required"`
		} `json:"items" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request: " + err.Error()})
		return
	}

	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Cek idempotency key
	var existingOrder models.Pesanan
	if err := tx.Where("idempotency_key = ?", req.IdempotencyKey).First(&existingOrder).Error; err == nil {
		tx.Commit()
		c.JSON(http.StatusOK, existingOrder)
		return
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error checking idempotency key"})
		return
	}

	// Validasi items
	if len(req.Items) == 0 {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"message": "Items are required"})
		return
	}

	// Cek user
	var user models.User
	if err := tx.Preload("Details").First(&user, req.UserID).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		return
	}

	// Generate order ID
	uniqueID := strings.ToUpper(strings.Replace(uuid.New().String(), "-", "", -1)[:8])
	orderID := "GS" + uniqueID

	// Buat pesanan
	pesanan := models.Pesanan{
		UserId:           req.UserID,
		OrderId:          orderID,
		IdempotencyKey:   req.IdempotencyKey,
		MetodePembayaran: req.MetodePembayaran,
		HargaRp:          int(math.Round(req.HargaRp)),
		Ongkir:           int(math.Round(req.Ongkir)),
		TotalBayar:       int(math.Round(req.TotalBayar)),
		PaymentStatus:    "unpaid",
		Status:           "pending",
		InvoiceNumber:    req.InvoiceNumber,
	}

	if err := tx.Create(&pesanan).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create order"})
		return
	}

	// Hapus item cart
	productIDs := make([]uint, len(req.Items))
	for i, item := range req.Items {
		productIDs[i] = item.ProductID
	}
	if err := tx.Where("user_id = ? AND product_id IN ?", req.UserID, productIDs).
		Delete(&models.Cart{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to delete cart items"})
		return
	}

	// Buat order items dan update stok
	for _, item := range req.Items {
		orderItem := models.OrderItem{
			PesananID:  pesanan.ID,
			ProductID:  item.ProductID,
			NamaProduk: item.NamaProduk,
			Harga:      int(math.Round(item.Harga)),
			Jumlah:     item.Jumlah,
			Berat:      int(math.Round(item.Berat)),
			Satuan:     item.Satuan,
			TotalHarga: int(math.Round(item.TotalHarga)),
		}

		if err := tx.Create(&orderItem).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create order item"})
			return
		}

		// Update stok produk
		var product models.Product
		if err := tx.First(&product, item.ProductID).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusNotFound, gin.H{"message": fmt.Sprintf("Product %d not found", item.ProductID)})
			return
		}

		if product.Stok < item.Jumlah {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{
				"message": fmt.Sprintf("Insufficient stock for %s. Available: %d", product.NameProduk, product.Stok),
			})
			return
		}

		product.Stok -= item.Jumlah
		if err := tx.Save(&product).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update product stock"})
			return
		}
	}

	// Handle bonus afiliasi
	if req.TotalBayar >= 200000 {
		currentUser := user
		bonusLevel := 1
		maxBonusBase := 200000.0

		for bonusLevel <= 2 {
			if currentUser.ReferredBy == nil {
				break
			}

			bonusPercentage := 0.0
			switch bonusLevel {
			case 1:
				bonusPercentage = 0.1
			case 2:
				bonusPercentage = 0.05
			}

			BonusAmount := maxBonusBase * bonusPercentage

			bonus := models.AfiliasiBonus{
				UserId:          *currentUser.ReferredBy,
				ReferralUserId:  req.UserID,
				PesananId:       pesanan.ID,
				BonusAmount:     BonusAmount,
				BonusLevel:      bonusLevel,
				ExpiryDate:      time.Now().AddDate(0, 1, 0),
				BonusReceivedAt: time.Now(),
			}

			if err := tx.Create(&bonus).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create affiliate bonus"})
				return
			}

			// Pindah ke level berikutnya
			if err := tx.First(&currentUser, *currentUser.ReferredBy).Error; err != nil {
				break
			}
			bonusLevel++
		}
	}

	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Transaction commit failed"})
		return
	}

	// Send notifications
	if user.FCMToken != "" {
		isValid := utils.IsFcmTokenValid(user.FCMToken)
		if isValid {
			firstName := "Pelanggan"
			if user.Details != nil && user.Details.Fullname != "" {
				nameParts := strings.Split(user.Details.Fullname, " ")
				if len(nameParts) > 0 {
					firstName = strings.Title(strings.ToLower(nameParts[0]))
				}
			}

			utils.SendOrderCODNotification(
				user.FCMToken,
				pesanan.OrderId,
				pesanan.TotalBayar,
				firstName,
			)
		} else {
			// Logging tambahan untuk debug
			log.Printf("Invalid FCM token for user ID: %d", user.ID)
			ctrl.DB.Model(&models.User{}).Where("id = ?", req.UserID).Update("fcm_token", nil)
		}
	}

	// Telegram notification - dengan format baru
	var fullPesanan models.Pesanan
	if err := ctrl.DB.
		Preload("User.Details").
		Preload("OrderItems").
		First(&fullPesanan, pesanan.ID).Error; err == nil {

		telegramMsg := utils.FormatTelegramOrderRpMessage(fullPesanan)
		utils.SendTelegramNotification(telegramMsg)
	} else {
		log.Printf("Gagal memuat data pesanan untuk notifikasi: %v", err)
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Order created successfully",
		"data":    pesanan,
	})
}

// BuatPesananPoin - Membuat pesanan dengan poin
func (ctrl *OrderController) BuatPesananPoin(c *gin.Context) {
	var req struct {
		UserID           uint    `json:"userId" binding:"required"`
		IdempotencyKey   string  `json:"idempotencyKey" binding:"required"`
		MetodePembayaran string  `json:"metodePembayaran" binding:"required"`
		HargaPoin        float64 `json:"hargaPoin"`
		Ongkir           float64 `json:"ongkir"`
		TotalBayar       float64 `json:"totalBayar" binding:"required"`
		InvoiceNumber    string  `json:"invoiceNumber"`
		Items            []struct {
			ProductID  uint    `json:"productId" binding:"required"`
			NamaProduk string  `json:"namaProduk" binding:"required"`
			Harga      float64 `json:"harga" binding:"required"`
			Jumlah     int     `json:"jumlah" binding:"required"`
			Berat      float64 `json:"berat"`
			Satuan     string  `json:"satuan"`
			TotalHarga float64 `json:"totalHarga" binding:"required"`
		} `json:"items" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request: " + err.Error()})
		return
	}

	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Cek idempotency key
	var existingOrder models.Pesanan
	if err := tx.Where("idempotency_key = ?", req.IdempotencyKey).First(&existingOrder).Error; err == nil {
		tx.Commit()
		c.JSON(http.StatusOK, existingOrder)
		return
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error checking idempotency key"})
		return
	}

	// Validasi items
	if len(req.Items) == 0 {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"message": "Items are required"})
		return
	}

	if req.TotalBayar <= 0 {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"message": "Total bayar harus lebih dari 0"})
		return
	}

	// Cek user
	var user models.User
	if err := tx.Preload("Details").First(&user, req.UserID).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		return
	}

	// Cek poin user
	var userPoints models.UserPoints
	if err := tx.Where("user_id = ?", req.UserID).First(&userPoints).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"message": "User points not found"})
		return
	}

	if userPoints.Points == 0 {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"message": "Anda tidak memiliki poin"})
		return
	}

	if userPoints.Points < int(req.TotalBayar) {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{
			"message": fmt.Sprintf("Poin tidak cukup. Poin Anda: %d", userPoints.Points),
		})
		return
	}

	// Generate order ID
	uniqueID := strings.ToUpper(strings.Replace(uuid.New().String(), "-", "", -1)[:8])
	orderID := "GS" + uniqueID

	// Kurangi poin user
	userPoints.Points -= int(req.TotalBayar)
	if err := tx.Save(&userPoints).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update user points"})
		return
	}

	// Buat pesanan
	pesanan := models.Pesanan{
		UserId:           req.UserID,
		OrderId:          orderID,
		IdempotencyKey:   req.IdempotencyKey,
		MetodePembayaran: req.MetodePembayaran,
		HargaPoin:        int(math.Round(req.HargaPoin)),
		Ongkir:           int(math.Round(req.Ongkir)),
		TotalBayar:       int(math.Round(req.TotalBayar)),
		PaymentStatus:    "paid",
		Status:           "pending",
		InvoiceNumber:    req.InvoiceNumber,
	}

	if err := tx.Create(&pesanan).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create order"})
		return
	}

	// Buat order items dan update stok
	for _, item := range req.Items {
		orderItem := models.OrderItem{
			PesananID:  pesanan.ID,
			ProductID:  item.ProductID,
			NamaProduk: item.NamaProduk,
			Harga:      int(math.Round(item.Harga)),
			Jumlah:     item.Jumlah,
			Berat:      int(math.Round(item.Berat)),
			Satuan:     item.Satuan,
			TotalHarga: int(math.Round(item.TotalHarga)),
		}

		if err := tx.Create(&orderItem).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create order item"})
			return
		}

		// Update stok produk
		var product models.Product
		if err := tx.First(&product, item.ProductID).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusNotFound, gin.H{"message": fmt.Sprintf("Product %d not found", item.ProductID)})
			return
		}

		if product.Stok < item.Jumlah {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{
				"message": fmt.Sprintf("Insufficient stock for %s. Available: %d", product.NameProduk, product.Stok),
			})
			return
		}

		product.Stok -= item.Jumlah
		if err := tx.Save(&product).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update product stock"})
			return
		}
	}

	// Handle bonus afiliasi jika menggunakan poin
	if req.TotalBayar >= 200 {
		// Ambil nilai poin dari settings
		var setting models.Setting
		if err := tx.Where("key = ?", "hargaPoin").First(&setting).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to get poin value"})
			return
		}

		nilaiPoin, err := strconv.Atoi(setting.Value)
		if err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Invalid poin value"})
			return
		}

		currentUser := user
		bonusLevel := 1
		maxBonusBase := 200.0

		for bonusLevel <= 2 {
			if currentUser.ReferredBy == nil {
				break
			}

			bonusPercentage := 0.0
			switch bonusLevel {
			case 1:
				bonusPercentage = 0.1
			case 2:
				bonusPercentage = 0.05
			}

			BonusAmount := maxBonusBase * float64(nilaiPoin) * bonusPercentage

			bonus := models.AfiliasiBonus{
				UserId:          *currentUser.ReferredBy,
				ReferralUserId:  req.UserID,
				PesananId:       pesanan.ID,
				BonusAmount:     BonusAmount,
				BonusLevel:      bonusLevel,
				ExpiryDate:      time.Now().AddDate(0, 1, 0),
				BonusReceivedAt: time.Now(),
			}

			if err := tx.Create(&bonus).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create affiliate bonus"})
				return
			}

			// Pindah ke level berikutnya
			if err := tx.First(&currentUser, *currentUser.ReferredBy).Error; err != nil {
				break
			}
			bonusLevel++
		}
	}

	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Transaction commit failed"})
		return
	}

	// Send notifications
	if user.FCMToken != "" {
		isValid := utils.IsFcmTokenValid(user.FCMToken)
		if isValid {
			firstName := "Pelanggan"
			if user.Details != nil && user.Details.Fullname != "" {
				nameParts := strings.Split(user.Details.Fullname, " ")
				if len(nameParts) > 0 {
					firstName = strings.Title(strings.ToLower(nameParts[0]))
				}
			}

			utils.SendOrderPoinNotification(
				user.FCMToken,
				pesanan.OrderId,
				pesanan.TotalBayar,
				firstName,
			)
		} else {
			// Logging tambahan untuk debug
			log.Printf("Invalid FCM token for user ID: %d", user.ID)
			ctrl.DB.Model(&models.User{}).Where("id = ?", req.UserID).Update("fcm_token", nil)
		}
	}

	// Telegram notification - dengan format baru
	var fullPesanan models.Pesanan
	if err := ctrl.DB.
		Preload("User.Details").
		Preload("OrderItems").
		First(&fullPesanan, pesanan.ID).Error; err == nil {

		telegramMsg := utils.FormatTelegramOrderPoinMessage(fullPesanan)
		utils.SendTelegramNotification(telegramMsg)
	} else {
		log.Printf("Gagal memuat data pesanan untuk notifikasi: %v", err)
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Order created successfully",
		"data":    pesanan,
	})
}

// BuatPesananPoinCart - Membuat pesanan poin dari keranjang
func (ctrl *OrderController) BuatPesananPoinCart(c *gin.Context) {
	var req struct {
		UserID           uint    `json:"userId" binding:"required"`
		IdempotencyKey   string  `json:"idempotencyKey" binding:"required"`
		MetodePembayaran string  `json:"metodePembayaran" binding:"required"`
		HargaPoin        float64 `json:"hargaPoin"`
		Ongkir           float64 `json:"ongkir"`
		TotalBayar       float64 `json:"totalBayar" binding:"required"`
		InvoiceNumber    string  `json:"invoiceNumber"`
		Items            []struct {
			ProductID  uint    `json:"productId" binding:"required"`
			NamaProduk string  `json:"namaProduk" binding:"required"`
			Harga      float64 `json:"harga" binding:"required"`
			Jumlah     int     `json:"jumlah" binding:"required"`
			Berat      float64 `json:"berat"`
			Satuan     string  `json:"satuan"`
			TotalHarga float64 `json:"totalHarga" binding:"required"`
		} `json:"items" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request: " + err.Error()})
		return
	}

	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Cek idempotency key
	var existingOrder models.Pesanan
	if err := tx.Where("idempotency_key = ?", req.IdempotencyKey).First(&existingOrder).Error; err == nil {
		tx.Commit()
		c.JSON(http.StatusOK, existingOrder)
		return
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Error checking idempotency key"})
		return
	}

	// Validasi items
	if len(req.Items) == 0 {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"message": "Items are required"})
		return
	}

	if req.TotalBayar <= 0 {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"message": "Total bayar harus lebih dari 0"})
		return
	}

	// Cek user
	var user models.User
	if err := tx.Preload("Details").First(&user, req.UserID).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
		return
	}

	// Cek poin user
	var userPoints models.UserPoints
	if err := tx.Where("user_id = ?", req.UserID).First(&userPoints).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"message": "User points not found"})
		return
	}

	if userPoints.Points == 0 {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"message": "Anda tidak memiliki poin"})
		return
	}

	if userPoints.Points < int(req.TotalBayar) {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{
			"message": fmt.Sprintf("Poin tidak cukup. Poin Anda: %d", userPoints.Points),
		})
		return
	}

	// Generate order ID
	uniqueID := strings.ToUpper(strings.Replace(uuid.New().String(), "-", "", -1)[:8])
	orderID := "GS" + uniqueID

	// Kurangi poin user
	userPoints.Points -= int(req.TotalBayar)
	if err := tx.Save(&userPoints).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update user points"})
		return
	}

	// Hapus item cart
	productIDs := make([]uint, len(req.Items))
	for i, item := range req.Items {
		productIDs[i] = item.ProductID
	}
	if err := tx.Where("user_id = ? AND product_id IN ?", req.UserID, productIDs).
		Delete(&models.Cart{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to delete cart items"})
		return
	}

	// Buat pesanan
	pesanan := models.Pesanan{
		UserId:           req.UserID,
		OrderId:          orderID,
		IdempotencyKey:   req.IdempotencyKey,
		MetodePembayaran: req.MetodePembayaran,
		HargaPoin:        int(math.Round(req.HargaPoin)),
		Ongkir:           int(math.Round(req.Ongkir)),
		TotalBayar:       int(math.Round(req.TotalBayar)),
		PaymentStatus:    "paid",
		Status:           "pending",
		InvoiceNumber:    req.InvoiceNumber,
	}

	if err := tx.Create(&pesanan).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create order"})
		return
	}

	// Buat order items dan update stok
	for _, item := range req.Items {
		orderItem := models.OrderItem{
			PesananID:  pesanan.ID,
			ProductID:  item.ProductID,
			NamaProduk: item.NamaProduk,
			Harga:      int(math.Round(item.Harga)),
			Jumlah:     item.Jumlah,
			Berat:      int(math.Round(item.Berat)),
			Satuan:     item.Satuan,
			TotalHarga: int(math.Round(item.TotalHarga)),
		}

		if err := tx.Create(&orderItem).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create order item"})
			return
		}

		// Update stok produk
		var product models.Product
		if err := tx.First(&product, item.ProductID).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusNotFound, gin.H{"message": fmt.Sprintf("Product %d not found", item.ProductID)})
			return
		}

		if product.Stok < item.Jumlah {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{
				"message": fmt.Sprintf("Insufficient stock for %s. Available: %d", product.NameProduk, product.Stok),
			})
			return
		}

		product.Stok -= item.Jumlah
		if err := tx.Save(&product).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update product stock"})
			return
		}
	}

	// Handle bonus afiliasi jika menggunakan poin
	if req.TotalBayar >= 200 {
		// Ambil nilai poin dari settings
		var setting models.Setting
		if err := tx.Where("key = ?", "hargaPoin").First(&setting).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to get poin value"})
			return
		}

		nilaiPoin, err := strconv.Atoi(setting.Value)
		if err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Invalid poin value"})
			return
		}

		currentUser := user
		bonusLevel := 1
		maxBonusBase := 200.0

		for bonusLevel <= 2 {
			if currentUser.ReferredBy == nil {
				break
			}

			bonusPercentage := 0.0
			switch bonusLevel {
			case 1:
				bonusPercentage = 0.1
			case 2:
				bonusPercentage = 0.05
			}

			BonusAmount := maxBonusBase * float64(nilaiPoin) * bonusPercentage

			bonus := models.AfiliasiBonus{
				UserId:          *currentUser.ReferredBy,
				ReferralUserId:  req.UserID,
				PesananId:       pesanan.ID,
				BonusAmount:     BonusAmount,
				BonusLevel:      bonusLevel,
				ExpiryDate:      time.Now().AddDate(0, 1, 0),
				BonusReceivedAt: time.Now(),
			}

			if err := tx.Create(&bonus).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create affiliate bonus"})
				return
			}

			// Pindah ke level berikutnya
			if err := tx.First(&currentUser, *currentUser.ReferredBy).Error; err != nil {
				break
			}
			bonusLevel++
		}
	}

	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Transaction commit failed"})
		return
	}

	// Send notifications
	if user.FCMToken != "" {
		isValid := utils.IsFcmTokenValid(user.FCMToken)
		if isValid {
			firstName := "Pelanggan"
			if user.Details != nil && user.Details.Fullname != "" {
				nameParts := strings.Split(user.Details.Fullname, " ")
				if len(nameParts) > 0 {
					firstName = strings.Title(strings.ToLower(nameParts[0]))
				}
			}

			utils.SendOrderPoinNotification(
				user.FCMToken,
				pesanan.OrderId,
				pesanan.TotalBayar,
				firstName,
			)
		} else {
			// Logging tambahan untuk debug
			log.Printf("Invalid FCM token for user ID: %d", user.ID)
			ctrl.DB.Model(&models.User{}).Where("id = ?", req.UserID).Update("fcm_token", nil)
		}
	}

	// Telegram notification - dengan format baru
	var fullPesanan models.Pesanan
	if err := ctrl.DB.
		Preload("User.Details").
		Preload("OrderItems").
		First(&fullPesanan, pesanan.ID).Error; err == nil {

		telegramMsg := utils.FormatTelegramOrderPoinMessage(fullPesanan)
		utils.SendTelegramNotification(telegramMsg)
	} else {
		log.Printf("Gagal memuat data pesanan untuk notifikasi: %v", err)
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Order created successfully",
		"data":    pesanan,
	})
}

// DeletePesanan handles DELETE /orders/:id
func (ctrl *OrderController) DeletePesanan(c *gin.Context) {
	id := c.Param("id")

	if err := ctrl.DB.Delete(&models.Pesanan{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Order deleted successfully"})
}
