package utils

import (
	"context"
	"log"
	"strconv"
	"strings"
	"sync"

	firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"github.com/google/uuid"
	"golang.org/x/text/language"
	"golang.org/x/text/message"
	"google.golang.org/api/option"
)

var (
	app     *firebase.App
	once    sync.Once
	errInit error
)

// Inisialisasi Firebase (hanya sekali)
func initFirebase() {
	credFilePath := "config/firebase-service-account.json"
	opt := option.WithCredentialsFile(credFilePath)
	once.Do(func() {
		ctx := context.Background()
		var err error
		app, err = firebase.NewApp(ctx, nil, opt)
		if err != nil {
			errInit = err
		}
	})
}

// Mendapatkan client messaging
func getMessagingClient() (*messaging.Client, error) {
	initFirebase()
	if errInit != nil {
		return nil, errInit
	}
	ctx := context.Background()
	return app.Messaging(ctx)
}

// Format mata uang IDR
func formatIDR(amount float64) string {
	p := message.NewPrinter(language.Indonesian)
	formattedNumber := p.Sprintf("%.0f", amount)

	return "Rp " + strings.ReplaceAll(formattedNumber, ",", ".")
}

// Notifikasi Topup
func SendTopupNotification(fcmToken string, points int, amount int, firstName string) {
	if fcmToken == "" {
		return
	}

	amountFloat := float64(amount) / 100.0
	formattedAmount := formatIDR(amountFloat)
	uuidVal := uuid.New().String()

	title := "Hai " + firstName + ", Top Up Berhasil! 🎉"
	body := "Anda berhasil top up " + strconv.Itoa(points) + " poin senilai " + formattedAmount + "."

	msg := &messaging.Message{
		Token: fcmToken,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data: map[string]string{
			"title":        title,
			"body":         body,
			"type":         "topup_success",
			"points":       strconv.Itoa(points),
			"amount":       strconv.Itoa(amount),
			"uuid":         uuidVal,
			"click_action": "FLUTTER_NOTIFICATION_CLICK",
		},
		Android: &messaging.AndroidConfig{
			Priority: "high",
			Notification: &messaging.AndroidNotification{
				ChannelID: "topup_channel",
				Sound:     "default",
				Tag:       uuidVal,
			},
		},
	}

	sendMessage(msg)
}

// Notifikasi Order COD
func SendOrderCODNotification(fcmToken, orderId string, totalAmount int, firstName string) {
	if fcmToken == "" {
		return
	}

	formattedAmount := formatIDR(float64(totalAmount))
	uuidVal := uuid.New().String()

	title := "Hai " + firstName + ", Pesanan COD Berhasil 🎉"
	body := "Terima kasih telah berbelanja! Pesanan #" + orderId + " senilai " + formattedAmount + " sudah kami terima."

	msg := &messaging.Message{
		Token: fcmToken,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data: map[string]string{
			"title":        title,
			"body":         body,
			"type":         "new_order",
			"orderId":      orderId,
			"uuid":         uuidVal,
			"click_action": "FLUTTER_NOTIFICATION_CLICK",
		},
		Android: &messaging.AndroidConfig{
			Priority: "high",
			Notification: &messaging.AndroidNotification{
				ChannelID: "order_channel",
				Sound:     "default",
				Tag:       uuidVal,
			},
		},
	}

	sendMessage(msg)
}

// Notifikasi Order Poin
func SendOrderPoinNotification(fcmToken, orderId string, totalAmount int, firstName string) {
	if fcmToken == "" {
		return
	}

	uuidVal := uuid.New().String()

	title := "Hai " + firstName + ", Pesanan POIN Berhasil 🎉"
	body := "Terima kasih telah berbelanja! Pesanan #" + orderId + " senilai " + strconv.Itoa(totalAmount) + " Poin sudah kami terima."

	msg := &messaging.Message{
		Token: fcmToken,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data: map[string]string{
			"title":        title,
			"body":         body,
			"type":         "new_order",
			"orderId":      orderId,
			"uuid":         uuidVal,
			"click_action": "FLUTTER_NOTIFICATION_CLICK",
		},
		Android: &messaging.AndroidConfig{
			Priority: "high",
			Notification: &messaging.AndroidNotification{
				ChannelID: "order_channel",
				Sound:     "default",
				Tag:       uuidVal,
			},
		},
	}

	sendMessage(msg)
}

// Notifikasi Update Status
func SendStatusNotification(fcmToken, orderId, status string) {
	if fcmToken == "" {
		return
	}

	formattedStatus := status
	if len(status) > 0 {
		formattedStatus = strings.ToUpper(status[:1]) + strings.ToLower(status[1:])
	}

	uuidVal := uuid.New().String()

	title := "Status Pesanan #" + orderId + " Diperbarui"
	body := "Pesanan Anda sekarang dalam status: " + formattedStatus

	msg := &messaging.Message{
		Token: fcmToken,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data: map[string]string{
			"title":        title,
			"body":         body,
			"type":         "status_update",
			"orderId":      orderId,
			"uuid":         uuidVal,
			"click_action": "FLUTTER_NOTIFICATION_CLICK",
		},
		Android: &messaging.AndroidConfig{
			Priority: "high",
			Notification: &messaging.AndroidNotification{
				ChannelID: "status_channel",
				Sound:     "default",
				Tag:       uuidVal,
			},
		},
	}

	sendMessage(msg)
}

// Validasi FCM Token
func IsFcmTokenValid(fcmToken string) bool {
	if fcmToken == "" {
		return false
	}

	client, err := getMessagingClient()
	if err != nil {
		log.Printf("Failed to get FCM client: %v", err)
		return false
	}

	msg := &messaging.Message{
		Token: fcmToken,
		Data:  map[string]string{"validation": "true"},
	}

	_, err = client.SendDryRun(context.Background(), msg)
	return err == nil
}

// Fungsi internal pengirim pesan
func sendMessage(msg *messaging.Message) {
	client, err := getMessagingClient()
	if err != nil {
		log.Printf("Failed to get FCM client: %v", err)
		return
	}

	_, err = client.Send(context.Background(), msg)
	if err != nil {
		log.Printf("Failed to send FCM message: %v", err)
	}
}
