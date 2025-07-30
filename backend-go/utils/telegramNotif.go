package utils

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
)

// FormatRupiah helper
func FormatRupiah(amount int) string {
	amountStr := fmt.Sprintf("%d", amount)
	var result []rune
	count := 0

	// Format dari belakang ke depan
	for i := len(amountStr) - 1; i >= 0; i-- {
		count++
		result = append([]rune{rune(amountStr[i])}, result...)
		if count%3 == 0 && i != 0 {
			result = append([]rune{'.'}, result...)
		}
	}
	return string(result)
}

func SendTelegramNotification(message string) {
	// Mendapatkan token dan chat ID dari environment variables
	token := os.Getenv("TELEGRAM_BOT_TOKEN")
	chatID := os.Getenv("TELEGRAM_CHAT_ID")

	if token == "" || chatID == "" {
		log.Println("Telegram bot token or chat ID not set in environment variables")
		return
	}

	// Membuat URL API Telegram
	apiURL := fmt.Sprintf("https://api.telegram.org/bot%s/sendMessage", token)

	// Membuat payload request
	payload := map[string]any{
		"chat_id":    chatID,
		"text":       message,
		"parse_mode": "HTML",
	}

	// Marshal payload menjadi JSON
	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		log.Printf("Error marshaling Telegram payload: %v", err)
		return
	}

	// Membuat HTTP request
	resp, err := http.Post(apiURL, "application/json", bytes.NewBuffer(jsonPayload))
	if err != nil {
		log.Printf("Failed to send Telegram notification: %v", err)
		return
	}
	defer resp.Body.Close()

	// Cek response status
	if resp.StatusCode != http.StatusOK {
		log.Printf("Telegram API returned non-OK status: %s", resp.Status)
	}
}
