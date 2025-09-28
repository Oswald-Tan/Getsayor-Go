package utils

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
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
	token := os.Getenv("TELEGRAM_BOT_TOKEN")
	rawChatIDs := os.Getenv("TELEGRAM_CHAT_ID")

	if token == "" || rawChatIDs == "" {
		log.Println("Telegram bot token or chat IDs not set")
		return
	}

	// Split chat IDs and remove any empty/whitespace-only entries
	chatIDs := strings.Split(rawChatIDs, ",")
	apiURL := fmt.Sprintf("https://api.telegram.org/bot%s/sendMessage", token)

	for _, id := range chatIDs {
		chatID := strings.TrimSpace(id)
		if chatID == "" {
			continue // Skip empty entries
		}

		payload := map[string]any{
			"chat_id":    chatID,
			"text":       message,
			"parse_mode": "HTML",
		}

		jsonPayload, err := json.Marshal(payload)
		if err != nil {
			log.Printf("[Chat %s] Error marshaling payload: %v", chatID, err)
			continue
		}

		resp, err := http.Post(apiURL, "application/json", bytes.NewBuffer(jsonPayload))
		if err != nil {
			log.Printf("[Chat %s] Send failed: %v", chatID, err)
			continue
		}

		defer resp.Body.Close()

		if resp.StatusCode != http.StatusOK {
			body, _ := io.ReadAll(resp.Body)
			log.Printf("[Chat %s] API error: %s | Response: %s", chatID, resp.Status, string(body))
		} else {
			log.Printf("[Chat %s] Notification sent", chatID)
		}
	}
}
