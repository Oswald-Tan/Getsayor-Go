package web

import (
	"errors"
	"net/http"
	"strconv"
	"strings"

	"backend-go/models"
	"backend-go/utils"

	"github.com/gin-gonic/gin"
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
		query = query.Joins("JOIN order_items ON order_items.pesanan_id = pesanan.id").
			Where("order_items.nama_produk LIKE ?", "%"+search+"%")
	}
	query.Count(&totalRows)

	totalPage := (int(totalRows) + limit - 1) / limit // Ceil division

	// Get orders
	var pesanan []models.Pesanan
	query = ctrl.DB.Preload("User", func(db *gorm.DB) *gorm.DB {
		return db.Preload("Details").Preload("Addresses", "is_default = ?", true)
	}).Preload("OrderItems.Product").Where(where)

	if search != "" {
		query = query.Joins("JOIN order_items ON order_items.pesanan_id = pesanan.id").
			Where("order_items.nama_produk LIKE ?", "%"+search+"%")
	}

	err := query.Order("pesanan.created_at DESC").
		Offset(offset).Limit(limit).Find(&pesanan).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data":      pesanan,
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
	err := ctrl.DB.Preload("OrderItems.Produk").
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

// UpdatePesananStatus handles PUT /orders/:id
func (ctrl *OrderController) UpdatePesananStatus(c *gin.Context) {
	id := c.Param("id")
	var req struct {
		Status string `json:"status"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request"})
		return
	}

	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	var pesanan models.Pesanan
	err := tx.Preload("User").Where("id = ?", id).First(&pesanan).Error
	if err != nil {
		tx.Rollback()
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"message": "Order not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	pesanan.Status = models.PesananStatus(req.Status)
	if req.Status == "delivered" {
		pesanan.PaymentStatus = models.PaymentPaid // Fixed: use constant
	}

	if err := tx.Save(&pesanan).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	// Send push notification
	if pesanan.User.FCMToken != "" {
		isValid := utils.IsFcmTokenValid(pesanan.User.FCMToken) // Fixed: single return value
		if isValid {
			firstName := ""
			if pesanan.User.Details != nil {
				nameParts := strings.Split(pesanan.User.Details.Fullname, " ")
				if len(nameParts) > 0 {
					firstName = strings.Title(strings.ToLower(nameParts[0]))
				}
			}
			if firstName == "" {
				firstName = "Pelanggan"
			}

			utils.SendStatusNotification(
				pesanan.User.FCMToken,
				pesanan.OrderId,
				string(pesanan.Status),
			)
		} else {
			tx.Model(&models.User{}).Where("id = ?", pesanan.UserId).Update("fcm_token", nil)
		}
	}

	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Transaction commit failed"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Order status updated successfully"})
}

// DeletePesanan handles DELETE /orders/:id
func (ctrl *OrderController) DeletePesanan(c *gin.Context) {
	id := c.Param("id")

	// Mulai transaksi database
	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 1. Hapus semua OrderItem terkait
	if err := tx.Where("pesanan_id = ?", id).Delete(&models.OrderItem{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to delete order items: " + err.Error()})
		return
	}

	// 2. Hapus Pesanan
	if err := tx.Delete(&models.Pesanan{}, id).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to delete order: " + err.Error()})
		return
	}

	// Commit transaksi jika berhasil
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Transaction failed: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Order deleted successfully"})
}
