package app

import (
	"crypto/rand"
	"fmt"
	"math"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type ProductController struct {
	DB *gorm.DB
}

func NewProductController(db *gorm.DB) *ProductController {
	return &ProductController{DB: db}
}

func GenerateUniqueFilename() string {
	b := make([]byte, 8)
	rand.Read(b)
	return fmt.Sprintf("%d_%x", time.Now().UnixNano(), b)
}

// GetProducts handles GET /products (admin)
func (ctrl *ProductController) GetProducts(c *gin.Context) {
	var products []models.Product

	// Preload ProductItems untuk mendapatkan data relasi
	if err := ctrl.DB.Preload("ProductItems").Find(&products).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error fetching products",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": products})
}

// GetProductsApp handles GET /products/app (for mobile app)
func (ctrl *ProductController) GetProductsApp(c *gin.Context) {
	// Parse query parameters
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "10"))
	category := c.Query("kategori")

	// Validate pagination
	if page < 1 {
		page = 1
	}
	if perPage < 1 || perPage > 100 {
		perPage = 10
	}

	offset := (page - 1) * perPage

	// Build base query
	baseQuery := ctrl.DB.Model(&models.Product{})
	if category != "" && category != "All" {
		baseQuery = baseQuery.Where("kategori LIKE ?", "%"+category+"%")
	}

	// Get total count (without preload)
	var total int64
	if err := baseQuery.Count(&total).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error counting products",
			"error":   err.Error(),
		})
		return
	}

	// Get products with preload
	var products []models.Product
	query := baseQuery.Preload("ProductItems") // Preload relasi disini
	if err := query.Offset(offset).
		Limit(perPage).
		Order("name_produk ASC").
		Find(&products).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error fetching products",
			"error":   err.Error(),
		})
		return
	}

	// Calculate total pages
	totalPages := int(math.Ceil(float64(total) / float64(perPage)))

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"data": products,
			"meta": gin.H{
				"total":      total,
				"page":       page,
				"perPage":    perPage,
				"totalPages": totalPages,
			},
		},
	})
}

// SearchProductsApp handles GET /products/search (for mobile app)
func (ctrl *ProductController) SearchProductsApp(c *gin.Context) {
	// Parse query parameters
	queryStr := c.Query("query")
	category := c.Query("kategori")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "10"))

	// Validate pagination
	if page < 1 {
		page = 1
	}
	if perPage < 1 || perPage > 100 {
		perPage = 10
	}

	offset := (page - 1) * perPage

	// Build query
	dbQuery := ctrl.DB.Model(&models.Product{})

	// Add search conditions if query is provided
	if queryStr != "" && strings.TrimSpace(queryStr) != "" {
		searchTerm := "%" + queryStr + "%"
		dbQuery = dbQuery.Where(
			"name_produk LIKE ? OR deskripsi LIKE ?",
			searchTerm, searchTerm,
		)
	}

	// Add category filter
	if category != "" && category != "All" {
		dbQuery = dbQuery.Where("kategori = ?", category)
	}

	// Get total count (tanpa preload untuk akurasi count)
	var total int64
	if err := dbQuery.Count(&total).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error counting products",
			"error":   err.Error(),
		})
		return
	}

	// Tambahkan preload untuk relasi ProductItems
	dbQuery = dbQuery.Preload("ProductItems")

	// Get products with relations
	var products []models.Product
	if err := dbQuery.Offset(offset).
		Limit(perPage).
		Order("name_produk ASC").
		Find(&products).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error fetching products",
			"error":   err.Error(),
		})
		return
	}

	// Calculate total pages
	totalPages := int(math.Ceil(float64(total) / float64(perPage)))

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"data": products,
			"meta": gin.H{
				"total":      total,
				"page":       page,
				"perPage":    perPage,
				"totalPages": totalPages,
			},
		},
	})
}

// GetProductById handles GET /products/:id
func (ctrl *ProductController) GetProductById(c *gin.Context) {
	id := c.Param("id")

	var product models.Product
	// Preload ProductItems untuk mendapatkan data relasi
	if err := ctrl.DB.Preload("ProductItems").First(&product, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Product not found",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": product})
}

// DeleteProduct handles DELETE /products/:id
func (ctrl *ProductController) DeleteProduct(c *gin.Context) {
	id := c.Param("id")

	// Get product
	var product models.Product
	if err := ctrl.DB.First(&product, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Product not found",
		})
		return
	}

	// Delete product
	if err := ctrl.DB.Delete(&product).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error deleting product",
			"error":   err.Error(),
		})
		return
	}

	// Delete image if exists
	if product.Image != "" {
		imagePath := "./uploads/" + product.Image
		if _, err := os.Stat(imagePath); err == nil {
			if err := os.Remove(imagePath); err != nil {
				fmt.Printf("Failed to delete image: %v\n", err)
			}
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Product deleted successfully",
	})
}
