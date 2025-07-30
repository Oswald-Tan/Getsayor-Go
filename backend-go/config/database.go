package config

import (
	// "backend-go/models"
	"fmt"
	"log"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func InitDB() *gorm.DB {
	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=disable",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_PORT"),
	)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// Cek koneksi database
	sqlDB, err := db.DB()
	if err != nil {
		log.Fatalf("Failed to get database instance: %v", err)
	}

	// Test ping database
	if err := sqlDB.Ping(); err != nil {
		log.Fatalf("Failed to ping database: %v", err)
	}
	log.Println("Database connection established")

	// Migrasi dengan penanganan error
	// err = db.AutoMigrate(
	// 	&models.Address{},
	// 	&models.AfiliasiBonus{},
	// 	&models.BankAccount{},
	// 	&models.CartItem{},
	// 	&models.Cart{},
	// 	&models.City{},
	// 	&models.DetailsUser{},
	// 	&models.Discount{},
	// 	&models.Favorite{},
	// 	&models.HargaPoin{},
	// 	&models.OrderItem{},
	// 	&models.Pesanan{},
	// 	&models.Poin{},
	// 	&models.Product{},
	// 	&models.Province{},
	// 	&models.Role{},
	// 	&models.ShippingRate{},
	// 	&models.TopUpPoin{},
	// 	&models.TotalBonus{},
	// 	&models.UserPoints{},
	// 	&models.UserStats{},
	// 	&models.User{},
	// 	&models.Setting{},
	// )

	if err != nil {
		log.Fatalf("Migration failed: %v", err)
	}
	log.Println("Database migrated successfully")

	return db
}
