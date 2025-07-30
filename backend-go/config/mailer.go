package config

import (
	"log"
	"os"

	"gopkg.in/gomail.v2"
)

type Mailer struct {
	dialer *gomail.Dialer
}

func NewMailer() *Mailer {
	// Konfigurasi email
	host := "smtp.hostinger.com"
	port := 465
	user := os.Getenv("EMAIL_USER")
	pass := os.Getenv("EMAIL_PASS")

	dialer := gomail.NewDialer(host, port, user, pass)
	return &Mailer{dialer: dialer}
}

func (m *Mailer) SendEmail(to, subject, body string) error {
	mailer := gomail.NewMessage()
	mailer.SetHeader("From", m.dialer.Username)
	mailer.SetHeader("To", to)
	mailer.SetHeader("Subject", subject)
	mailer.SetBody("text/html", body)

	if err := m.dialer.DialAndSend(mailer); err != nil {
		log.Printf("Failed to send email: %v", err)
		return err
	}
	return nil
}
