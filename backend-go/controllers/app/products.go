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

	if err := ctrl.DB.Find(&products).Error; err != nil {
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

	// Build query
	query := ctrl.DB.Model(&models.Product{})
	if category != "" && category != "All" {
		query = query.Where("kategori LIKE ?", "%"+category+"%")
	}

	// Get total count
	var total int64
	if err := query.Count(&total).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error counting products",
			"error":   err.Error(),
		})
		return
	}

	// Get products
	var products []models.Product
	if err := query.Offset(offset).Limit(perPage).Order("name_produk ASC").Find(&products).Error; err != nil {
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

	// Get total count
	var total int64
	if err := dbQuery.Count(&total).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error counting products",
			"error":   err.Error(),
		})
		return
	}

	// Get products
	var products []models.Product
	if err := dbQuery.Offset(offset).Limit(perPage).Order("name_produk ASC").Find(&products).Error; err != nil {
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
	if err := ctrl.DB.First(&product, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Product not found",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": product})
}

type CreateProductRequest struct {
	NameProduk string `form:"nameProduk" binding:"required"`
	Deskripsi  string `form:"deskripsi" binding:"required"`
	Kategori   string `form:"kategori" binding:"required"`
	Stok       string `form:"stok" binding:"required"`    // Ubah ke string
	HargaRp    string `form:"hargaRp" binding:"required"` // Ubah ke string
	Jumlah     string `form:"jumlah" binding:"required"`  // Ubah ke string
	Satuan     string `form:"satuan" binding:"required"`
}

// CreateProduct handles POST /products
func (ctrl *ProductController) CreateProduct(c *gin.Context) {
	var req CreateProductRequest
	if err := c.ShouldBind(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	// Konversi string ke int/float
	stok, err := strconv.Atoi(req.Stok)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid stok format",
		})
		return
	}

	hargaRp, err := strconv.ParseFloat(req.HargaRp, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid hargaRp format",
		})
		return
	}

	jumlah, err := strconv.Atoi(req.Jumlah)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid jumlah format",
		})
		return
	}

	// Get point value setting
	var setting models.Setting
	if err := ctrl.DB.Where("key = ?", "hargaPoin").First(&setting).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Harga Poin setting not found",
		})
		return
	}

	// Convert setting value to float
	poinValue, err := strconv.ParseFloat(setting.Value, 64)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Invalid hargaPoin value",
		})
		return
	}

	// Calculate point price
	hargaPoin := int(math.Round(hargaRp / poinValue))

	// Get uploaded filename from middleware context
	imageFilename := c.GetString("fileName")

	// Convert HargaRp to int before storing
	hargaRpInt := int(math.Round(hargaRp))

	// Create product
	product := models.Product{
		NameProduk: req.NameProduk,
		Deskripsi:  req.Deskripsi,
		Kategori:   req.Kategori,
		Stok:       stok,
		HargaPoin:  hargaPoin,
		HargaRp:    hargaRpInt,
		Jumlah:     jumlah,
		Satuan:     req.Satuan,
		Image:      imageFilename,
	}

	if err := ctrl.DB.Create(&product).Error; err != nil {
		// Clean up uploaded file if database error
		if imageFilename != "" {
			os.Remove("./uploads/" + imageFilename)
		}

		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error creating product",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "Product created successfully",
		"data":    product,
	})
}

type UpdateProductRequest struct {
	NameProduk string  `form:"nameProduk"`
	Deskripsi  string  `form:"deskripsi"`
	Kategori   string  `form:"kategori"`
	Stok       int     `form:"stok"`
	HargaRp    float64 `form:"hargaRp"`
	Jumlah     int     `form:"jumlah"`
	Satuan     string  `form:"satuan"`
}

// UpdateProduct handles PATCH /products/:id
func (ctrl *ProductController) UpdateProduct(c *gin.Context) {
	id := c.Param("id")
	var req UpdateProductRequest

	if err := c.ShouldBind(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	// Get existing product
	var product models.Product
	if err := ctrl.DB.First(&product, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Product not found",
		})
		return
	}

	// Validate fields
	if req.NameProduk != "" && (len(req.NameProduk) < 3 || len(req.NameProduk) > 100) {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Name must be between 3 and 100 characters",
		})
		return
	}

	if req.Stok < 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Stock must be non-negative",
		})
		return
	}

	if req.HargaRp < 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Price must be non-negative",
		})
		return
	}

	if req.Jumlah < 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Quantity must be non-negative",
		})
		return
	}

	// Get uploaded filename from middleware context
	newImageFilename := c.GetString("fileName") // PERBAIKAN DI SINI
	var oldImageFilename string

	if newImageFilename != "" {
		// Save old image for cleanup
		oldImageFilename = product.Image
	}

	// Convert request value to int for comparison
	hargaRpInt := int(math.Round(req.HargaRp))

	// Update point price if hargaRp changed
	if req.HargaRp >= 0 && hargaRpInt != product.HargaRp {
		// Get point value setting
		var setting models.Setting
		if err := ctrl.DB.Where("key = ?", "hargaPoin").First(&setting).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Harga Poin setting not found",
			})
			return
		}

		// Convert setting value to float
		poinValue, err := strconv.ParseFloat(setting.Value, 64)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Invalid hargaPoin value",
			})
			return
		}

		// Calculate new point price
		product.HargaPoin = int(math.Round(req.HargaRp / poinValue))
		product.HargaRp = hargaRpInt
	}

	// Update fields
	if req.NameProduk != "" {
		product.NameProduk = req.NameProduk
	}
	if req.Deskripsi != "" {
		product.Deskripsi = req.Deskripsi
	}
	if req.Kategori != "" {
		product.Kategori = req.Kategori
	}
	if req.Stok > 0 {
		product.Stok = req.Stok
	}
	if req.Jumlah > 0 {
		product.Jumlah = req.Jumlah
	}
	if req.Satuan != "" {
		product.Satuan = req.Satuan
	}
	if newImageFilename != "" {
		product.Image = newImageFilename
	}

	// Save changes
	if err := ctrl.DB.Save(&product).Error; err != nil {
		// Clean up new file if database error
		if newImageFilename != "" {
			os.Remove("./uploads/" + newImageFilename)
		}

		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error updating product",
			"error":   err.Error(),
		})
		return
	}

	// Clean up old image if new one was uploaded
	if oldImageFilename != "" {
		os.Remove("./uploads/" + oldImageFilename)
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Product updated successfully",
		"data":    product,
	})
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
