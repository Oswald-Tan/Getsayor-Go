package middleware

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

// UploadConfig konfigurasi untuk middleware upload
type UploadConfig struct {
	FieldName   string
	Destination string
	AllowedMIME []string
	MaxSize     int64
}

// UploadFile is a simplified wrapper for common image uploads
func UploadFile(fieldName string) gin.HandlerFunc {
	return UploadMiddleware(UploadConfig{
		FieldName:   fieldName,
		Destination: "./uploads",
		AllowedMIME: []string{"image/jpeg", "image/png", "image/gif", "image/webp"},
		MaxSize:     5 << 20, // 5 MB
	})
}

// GenerateUniqueFilename menghasilkan nama file unik
func GenerateUniqueFilename() string {
	b := make([]byte, 8)
	if _, err := rand.Read(b); err != nil {
		return fmt.Sprintf("%d", time.Now().UnixNano())
	}
	return fmt.Sprintf("%d_%s", time.Now().UnixNano(), hex.EncodeToString(b))
}

// UploadMiddleware membuat middleware untuk menangani file upload
func UploadMiddleware(config UploadConfig) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Parse multipart form
		err := c.Request.ParseMultipartForm(config.MaxSize)
		if err != nil {
			// Handle case where there's no multipart form
			if errors.Is(err, http.ErrNotMultipart) {
				c.Next()
				return
			}
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
				"success": false,
				"error":   "Failed to parse multipart form: " + err.Error(),
			})
			return
		}

		// Dapatkan file dari form
		file, header, err := c.Request.FormFile(config.FieldName)
		if err != nil {
			// Handle case where no file is uploaded
			if errors.Is(err, http.ErrMissingFile) {
				c.Next()
				return
			}
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
				"success": false,
				"error":   "File not found in request: " + err.Error(),
			})
			return
		}
		defer file.Close()

		// Validasi tipe file
		buffer := make([]byte, 512)
		if _, err := file.Read(buffer); err != nil && err != io.EOF {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"error":   "Failed to read file: " + err.Error(),
			})
			return
		}

		mimeType := http.DetectContentType(buffer)
		valid := false
		for _, allowed := range config.AllowedMIME {
			if mimeType == allowed {
				valid = true
				break
			}
		}

		if !valid {
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{
				"success": false,
				"error":   "Invalid file type. Allowed types: " + strings.Join(config.AllowedMIME, ", "),
			})
			return
		}

		// Reset file reader
		if _, err := file.Seek(0, 0); err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"error":   "Failed to reset file reader: " + err.Error(),
			})
			return
		}

		// Generate nama file unik
		ext := filepath.Ext(header.Filename)
		newFilename := GenerateUniqueFilename() + ext
		filePath := filepath.Join(config.Destination, newFilename)

		// Buat folder jika belum ada
		if _, err := os.Stat(config.Destination); os.IsNotExist(err) {
			if err := os.MkdirAll(config.Destination, 0755); err != nil {
				c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
					"success": false,
					"error":   "Failed to create upload directory: " + err.Error(),
				})
				return
			}
		}

		// Simpan file
		out, err := os.Create(filePath)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"error":   "Failed to create file: " + err.Error(),
			})
			return
		}
		defer out.Close()

		if _, err := io.Copy(out, file); err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"error":   "Failed to save file: " + err.Error(),
			})
			return
		}

		// Tambahkan info file ke context
		c.Set("filePath", filePath)
		c.Set("fileName", newFilename)
		c.Set("fileSize", header.Size)
		c.Set("fileType", mimeType)

		c.Next()
	}
}
