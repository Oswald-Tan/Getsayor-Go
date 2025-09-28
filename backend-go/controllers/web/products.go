package web

import (
	"crypto/rand"
	"encoding/json"
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
	page, _ := strconv.Atoi(c.DefaultQuery("page", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	search := c.Query("search")
	offset := page * limit

	var totalRows int64
	var products []models.Product

	// Create base query without pagination
	baseQuery := ctrl.DB.Model(&models.Product{})

	// Apply search filter with subquery
	if search != "" {
		searchTerm := "%" + search + "%"
		subQuery := ctrl.DB.Model(&models.Product{}).
			Select("id").
			Joins("LEFT JOIN product_items ON product_items.product_id = products.id").
			Where(
				"products.name_produk ILIKE ? OR "+
					"products.deskripsi ILIKE ? OR "+
					"products.kategori ILIKE ? OR "+
					"product_items.satuan ILIKE ?",
				searchTerm, searchTerm, searchTerm, searchTerm,
			).
			Group("products.id")

		baseQuery = baseQuery.Where("products.id IN (?)", subQuery)
	}

	// Get total count
	if err := baseQuery.Count(&totalRows).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error counting products",
			"error":   err.Error(),
		})
		return
	}

	// Fetch products with their variants
	query := baseQuery.
		Preload("ProductItems").
		Order("products.created_at DESC").
		Offset(offset).
		Limit(limit)

	if err := query.Find(&products).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error fetching products",
			"error":   err.Error(),
		})
		return
	}

	// Calculate total pages
	totalPages := int(math.Ceil(float64(totalRows) / float64(limit)))

	// Create response structure
	type ProductItemResponse struct {
		ID        uint   `json:"id"`
		Stok      int    `json:"stok"`
		HargaPoin int    `json:"hargaPoin"`
		HargaRp   int    `json:"hargaRp"`
		Jumlah    int    `json:"jumlah"`
		Satuan    string `json:"satuan"`
	}

	type ProductResponse struct {
		ID           uint                  `json:"id"`
		NameProduk   string                `json:"nameProduk"`
		Deskripsi    string                `json:"deskripsi"`
		Kategori     string                `json:"kategori"`
		Image        string                `json:"image"`
		CreatedAt    time.Time             `json:"createdAt"`
		UpdatedAt    time.Time             `json:"updatedAt"`
		ProductItems []ProductItemResponse `json:"productItems"`
	}

	// Map products to response format
	response := make([]ProductResponse, len(products))
	for i, p := range products {
		items := make([]ProductItemResponse, len(p.ProductItems))
		for j, item := range p.ProductItems {
			items[j] = ProductItemResponse{
				ID:        item.ID,
				Stok:      item.Stok,
				HargaPoin: item.HargaPoin,
				HargaRp:   item.HargaRp,
				Jumlah:    item.Jumlah,
				Satuan:    item.Satuan,
			}
		}

		response[i] = ProductResponse{
			ID:           p.ID,
			NameProduk:   p.NameProduk,
			Deskripsi:    p.Deskripsi,
			Kategori:     p.Kategori,
			Image:        p.Image,
			CreatedAt:    p.CreatedAt,
			UpdatedAt:    p.UpdatedAt,
			ProductItems: items,
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"success":    true,
		"data":       response,
		"page":       page,
		"limit":      limit,
		"totalPages": totalPages,
		"totalRows":  totalRows,
	})
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
	if err := ctrl.DB.
		Preload("ProductItems").
		First(&product, id).
		Error; err != nil {

		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Product not found",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": product})
}

// Valid units for product variants
var validUnits = map[string]bool{
	"gram":     true,
	"kilogram": true,
	"ikat":     true,
	"biji":     true,
	"buah":     true,
	"pcs":      true,
}

type ProductVariantRequest struct {
	Stok         string `form:"stok" json:"stok" binding:"required"`
	HargaRp      string `form:"hargaRp" json:"hargaRp" binding:"required"`
	Jumlah       string `form:"jumlah" json:"jumlah" binding:"required"`
	Satuan       string `form:"satuan" json:"satuan" binding:"required"`
	BeratPerUnit string `form:"beratPerUnit" json:"beratPerUnit"`
	IsBaseUnit   string `form:"isBaseUnit" json:"isBaseUnit"`
}

type CreateProductRequest struct {
	NameProduk string `form:"nameProduk" binding:"required"`
	Deskripsi  string `form:"deskripsi" binding:"required"`
	Kategori   string `form:"kategori" binding:"required"`
	Variants   string `form:"variants"`
	Stok       string `form:"stok"`
	HargaRp    string `form:"hargaRp"`
	Jumlah     string `form:"jumlah"`
	Satuan     string `form:"satuan"`
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

	var variants []ProductVariantRequest

	// Parse variants if provided as JSON string
	if req.Variants != "" {
		if err := json.Unmarshal([]byte(req.Variants), &variants); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid variants format: " + err.Error(),
			})
			return
		}
	} else {
		// Use individual fields if variants not provided
		if req.Stok == "" || req.HargaRp == "" || req.Jumlah == "" || req.Satuan == "" {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "All variant fields are required when not using variants JSON",
			})
			return
		}
		variants = []ProductVariantRequest{
			{
				Stok:    req.Stok,
				HargaRp: req.HargaRp,
				Jumlah:  req.Jumlah,
				Satuan:  req.Satuan,
			},
		}
	}

	// Validate at least one variant exists
	if len(variants) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "At least one product variant is required",
		})
		return
	}

	// Limit number of variants
	if len(variants) > 10 {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Maximum 10 variants per product allowed",
		})
		return
	}

	// Validate units and check for duplicates
	seenVariants := make(map[string]bool)
	for i, variant := range variants {
		// Convert to lowercase for comparison
		satuanLower := strings.ToLower(variant.Satuan)

		if !validUnits[satuanLower] {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": fmt.Sprintf("Invalid unit '%s' in variant %d. Valid units: gram, kilogram, ikat, biji, buah, pcs", variant.Satuan, i+1),
			})
			return
		}

		// Gunakan satuanLower untuk duplicate check
		key := variant.Jumlah + satuanLower
		if seenVariants[key] {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": fmt.Sprintf("Duplicate variant: %s %s", variant.Jumlah, variant.Satuan),
			})
			return
		}
		seenVariants[key] = true
	}

	// Get point conversion setting
	var setting models.Setting
	if err := ctrl.DB.Where("key = ?", "hargaPoin").First(&setting).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Harga Poin setting not found",
		})
		return
	}

	poinValue, err := strconv.ParseFloat(setting.Value, 64)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Invalid hargaPoin value",
		})
		return
	}

	// Get uploaded filename
	imageFilename := c.GetString("fileName")

	// Create main product
	product := models.Product{
		NameProduk: req.NameProduk,
		Deskripsi:  req.Deskripsi,
		Kategori:   req.Kategori,
		Image:      imageFilename,
	}

	// Start database transaction
	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Save main product
	if err := tx.Create(&product).Error; err != nil {
		tx.Rollback()
		// Clean up uploaded file
		if imageFilename != "" {
			os.Remove("./uploads/" + imageFilename)
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error creating main product",
			"error":   err.Error(),
		})
		return
	}

	// Create product variants
	for _, variant := range variants {
		// Convert values with better error messages
		stok, err := strconv.Atoi(variant.Stok)
		if err != nil {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid stock value: " + variant.Stok,
			})
			return
		}

		hargaRp, err := strconv.ParseFloat(variant.HargaRp, 64)
		if err != nil {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid price value: " + variant.HargaRp,
			})
			return
		}

		jumlah, err := strconv.Atoi(variant.Jumlah)
		if err != nil {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid quantity value: " + variant.Jumlah,
			})
			return
		}

		// Calculate point price
		hargaPoin := int(math.Round(hargaRp / poinValue))
		hargaRpInt := int(math.Round(hargaRp))

		// Create variant
		productItem := models.ProductItem{
			ProductID: product.ID,
			Stok:      stok,
			HargaPoin: hargaPoin,
			HargaRp:   hargaRpInt,
			Jumlah:    jumlah,
			Satuan:    variant.Satuan,
		}

		if err := tx.Create(&productItem).Error; err != nil {
			tx.Rollback()
			// Clean up uploaded file
			if imageFilename != "" {
				os.Remove("./uploads/" + imageFilename)
			}
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Error creating product variant",
				"error":   err.Error(),
			})
			return
		}
	}

	// Commit transaction
	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Transaction commit failed",
			"error":   err.Error(),
		})
		return
	}

	// Reload product with variants
	if err := ctrl.DB.Preload("ProductItems").First(&product, product.ID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error fetching created product",
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

type ProductVariantUpdateRequest struct {
	ID      uint   `form:"id" json:"id"`
	Stok    string `form:"stok" json:"stok"`
	HargaRp string `form:"hargaRp" json:"hargaRp"`
	Jumlah  string `form:"jumlah" json:"jumlah"`
	Satuan  string `form:"satuan" json:"satuan"`
}

type UpdateProductRequest struct {
	NameProduk string `form:"nameProduk"`
	Deskripsi  string `form:"deskripsi"`
	Kategori   string `form:"kategori"`
	Variants   string `form:"variants"` // Ubah menjadi string untuk JSON
}

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

	// Unmarshal variants JSON
	var variantReqs []ProductVariantUpdateRequest
	if req.Variants != "" {
		if err := json.Unmarshal([]byte(req.Variants), &variantReqs); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": "Invalid variants format: " + err.Error(),
			})
			return
		}
	}

	// Get existing product
	var product models.Product
	if err := ctrl.DB.Preload("ProductItems").First(&product, id).Error; err != nil {
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

	// Get uploaded filename from middleware context
	newImageFilename := c.GetString("fileName")
	var oldImageFilename string

	if newImageFilename != "" {
		// Save old image for cleanup
		oldImageFilename = product.Image
	}

	// Update product fields
	updateFields := false
	if req.NameProduk != "" {
		product.NameProduk = req.NameProduk
		updateFields = true
	}
	if req.Deskripsi != "" {
		product.Deskripsi = req.Deskripsi
		updateFields = true
	}
	if req.Kategori != "" {
		product.Kategori = req.Kategori
		updateFields = true
	}
	if newImageFilename != "" {
		product.Image = newImageFilename
		updateFields = true
	}

	// Start database transaction
	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Save product changes if any
	if updateFields {
		if err := tx.Save(&product).Error; err != nil {
			tx.Rollback()
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
	}

	// Get point conversion setting
	var setting models.Setting
	if err := tx.Where("key = ?", "hargaPoin").First(&setting).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Harga Poin setting not found",
		})
		return
	}

	poinValue, err := strconv.ParseFloat(setting.Value, 64)
	if err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Invalid hargaPoin value",
		})
		return
	}

	// Update variants
	for _, variantReq := range variantReqs {
		var productItem models.ProductItem

		// Cari varian yang ada atau buat baru
		if variantReq.ID != 0 {
			// Cari varian yang sudah ada
			found := false
			for _, item := range product.ProductItems {
				if item.ID == variantReq.ID {
					productItem = item
					found = true
					break
				}
			}

			if !found {
				tx.Rollback()
				c.JSON(http.StatusNotFound, gin.H{
					"success": false,
					"message": "Product variant not found",
				})
				return
			}
		} else {
			// Buat varian baru
			productItem = models.ProductItem{
				ProductID: product.ID,
			}
		}

		// Update fields jika diberikan
		if variantReq.Stok != "" {
			stok, err := strconv.Atoi(variantReq.Stok)
			if err != nil {
				tx.Rollback()
				c.JSON(http.StatusBadRequest, gin.H{
					"success": false,
					"message": "Invalid stok format in variant",
				})
				return
			}
			productItem.Stok = stok
		}

		if variantReq.HargaRp != "" {
			hargaRp, err := strconv.ParseFloat(variantReq.HargaRp, 64)
			if err != nil {
				tx.Rollback()
				c.JSON(http.StatusBadRequest, gin.H{
					"success": false,
					"message": "Invalid hargaRp format in variant",
				})
				return
			}
			productItem.HargaRp = int(math.Round(hargaRp))
			productItem.HargaPoin = int(math.Round(hargaRp / poinValue))
		}

		if variantReq.Jumlah != "" {
			jumlah, err := strconv.Atoi(variantReq.Jumlah)
			if err != nil {
				tx.Rollback()
				c.JSON(http.StatusBadRequest, gin.H{
					"success": false,
					"message": "Invalid jumlah format in variant",
				})
				return
			}
			productItem.Jumlah = jumlah
		}

		if variantReq.Satuan != "" {
			// Validasi satuan
			satuanLower := strings.ToLower(variantReq.Satuan)
			if !validUnits[satuanLower] {
				tx.Rollback()
				c.JSON(http.StatusBadRequest, gin.H{
					"success": false,
					"message": fmt.Sprintf("Invalid unit '%s'. Valid units: gram, kilogram, ikat, biji, buah, pcs", variantReq.Satuan),
				})
				return
			}
			productItem.Satuan = variantReq.Satuan
		}

		// Save variant
		if err := tx.Save(&productItem).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Error updating product variant",
				"error":   err.Error(),
			})
			return
		}
	}

	// Commit transaction
	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Transaction commit failed",
			"error":   err.Error(),
		})
		return
	}

	// Clean up old image if new one was uploaded
	if oldImageFilename != "" && newImageFilename != "" {
		os.Remove("./uploads/" + oldImageFilename)
	}

	// Reload product with variants
	if err := ctrl.DB.Preload("ProductItems").First(&product, product.ID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Error fetching updated product",
			"error":   err.Error(),
		})
		return
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
