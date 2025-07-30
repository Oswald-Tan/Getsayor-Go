package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-contrib/sessions"
	"github.com/gin-contrib/sessions/cookie"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"github.com/robfig/cron/v3"
	"gorm.io/gorm"

	"backend-go/config"
	approutes "backend-go/routes/app"
	webroutes "backend-go/routes/web"
	"backend-go/tasks"
)

const (
	TelegramBotToken = "7451953028:AAHmhVnbaKDRldVU2KxqsRDSADaWeV6cZSs" // Ganti dengan token bot kamu
	TelegramChatID   = 1674661428                                       // Ganti dengan chat_id kamu (akun Telegram admin)
)

// Payload request ke Telegram API
type TelegramMessage struct {
	ChatID int64  `json:"chat_id"`
	Text   string `json:"text"`
}

func sendTelegramMessage(chatID int64, message string) error {
	url := fmt.Sprintf("https://api.telegram.org/bot%s/sendMessage", TelegramBotToken)

	payload := TelegramMessage{
		ChatID: chatID,
		Text:   message,
	}

	body, _ := json.Marshal(payload)
	resp, err := http.Post(url, "application/json", bytes.NewBuffer(body))
	if err != nil {
		return fmt.Errorf("gagal kirim request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("telegram API error: %s", resp.Status)
	}
	return nil
}

// CustomStaticMiddleware adalah handler untuk static files dengan header khusus
func CustomStaticMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Dapatkan hanya nama file dari URL
		fileName := strings.TrimPrefix(c.Request.URL.Path, "/uploads/")
		filePath := filepath.Join("./uploads", fileName)

		c.Header("Cache-Control", "public, max-age=31536000, immutable")

		// Buka file
		file, err := os.Open(filePath)
		if err != nil {
			c.AbortWithStatus(http.StatusNotFound)
			return
		}
		defer file.Close()

		// Dapatkan info file
		fileInfo, err := file.Stat()
		if err != nil {
			c.AbortWithStatus(http.StatusInternalServerError)
			return
		}

		// Serve file langsung
		http.ServeContent(c.Writer, c.Request, fileName, fileInfo.ModTime(), file)
	}
}

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Fatal("Error loading .env file")
	}

	// Initialize database
	db := config.InitDB()

	// Setup Gin
	app := gin.Default()

	// Setup CORS middleware
	allowedOrigins := strings.Split(os.Getenv("ALLOWED_ORIGINS"), ",")

	// Bersihkan whitespace di setiap origin
	for i, origin := range allowedOrigins {
		allowedOrigins[i] = strings.TrimSpace(origin)
	}

	// Jika environment variable kosong, gunakan default
	if len(allowedOrigins) == 1 && allowedOrigins[0] == "" {
		allowedOrigins = []string{"http://localhost:5173", "http://localhost:5174"}
	}

	app.Use(cors.New(cors.Config{
		AllowOrigins:     allowedOrigins,
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "Accept"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour, // Cache preflight request selama 12 jam
	}))

	store := cookie.NewStore([]byte(os.Getenv("SESSION_SECRET")))
	store.Options(sessions.Options{
		Path:     "/",
		Domain:   "",        // Kosongkan untuk localhost (akan bekerja lebih baik)
		MaxAge:   86400 * 7, // 7 hari
		HttpOnly: true,
		Secure:   os.Getenv("ENV") == "production", // false di development
		SameSite: http.SameSiteLaxMode,
	})
	app.Use(sessions.Sessions("mysession", store))

	// Tambahkan middleware untuk menyetel database ke context
	app.Use(func(c *gin.Context) {
		c.Set("db", db)
		c.Next()
	})

	// Buat folder uploads jika belum ada
	if _, err := os.Stat("./uploads"); os.IsNotExist(err) {
		if err := os.MkdirAll("./uploads", 0755); err != nil {
			log.Fatalf("Failed to create uploads directory: %v", err)
		}
	}

	// Handler untuk static files dengan header khusus
	app.GET("/uploads/*filepath", CustomStaticMiddleware())

	// Register routes
	webroutes.SetupWebRoutes(app, db)
	approutes.SetupAppRoutes(app, db)

	// Start cron jobs
	startCronJobs(db)

	// Tambahkan endpoint Hello World
	app.GET("/api/v1/hello-world", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello, World!",
		})
	})

	// Route sederhana untuk tes push notif
	app.GET("/api/v1/test-notif", func(c *gin.Context) {
		err := sendTelegramMessage(TelegramChatID, "Notifikasi dari backend Go 🚀")

		if err != nil {
			log.Println("Gagal kirim notifikasi:", err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"error":   err.Error(),
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"message": "Notifikasi Telegram berhasil dikirim!",
		})
	})

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}
	app.Run(":" + port)
}

func startCronJobs(db *gorm.DB) {
	c := cron.New()

	// Schedule bonus expiration check
	_, err := c.AddFunc("0 0 * * *", func() {
		tasks.CheckExpiredBonuses(db)
	})

	if err != nil {
		log.Fatal("Error scheduling cron job:", err)
	}

	c.Start()
}
