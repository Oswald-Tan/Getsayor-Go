package utils

import (
	"crypto/rand"
	"fmt"
	"strings"
	"time"

	"backend-go/models"
)

// GenerateUniqueFilename generates a unique filename
func GenerateUniqueFilename() string {
	b := make([]byte, 8)
	rand.Read(b)
	return fmt.Sprintf("%d_%x", time.Now().UnixNano(), b)
}

// FormatTelegramOrderMessage RP membuat pesan notifikasi Telegram
func FormatTelegramOrderRpMessage(pesanan models.Pesanan) string {
	var sb strings.Builder

	// Header
	sb.WriteString(fmt.Sprintf("🛒 <b>ORDER BARUU #%s</b>\n", pesanan.OrderId))
	sb.WriteString("──────────────────\n")

	// Pelanggan
	sb.WriteString("<b>Pelanggan:</b>\n")
	if pesanan.User.Details != nil {
		sb.WriteString(fmt.Sprintf("├ %s\n", pesanan.User.Details.Fullname))
		sb.WriteString(fmt.Sprintf("╰ %s\n", pesanan.User.Details.PhoneNumber))
	} else {
		sb.WriteString("├ Pelanggan Tidak Dikenal\n")
		sb.WriteString("╰ -\n")
	}
	sb.WriteString("──────────────────\n")

	// Produk
	sb.WriteString(fmt.Sprintf("<b>Produk (%d item):</b>\n", len(pesanan.OrderItems)))
	for i, item := range pesanan.OrderItems {
		prefix := "├"
		if i == len(pesanan.OrderItems)-1 {
			prefix = "╰"
		}
		sb.WriteString(fmt.Sprintf("%s %s\n", prefix, item.NamaProduk))
		sb.WriteString(fmt.Sprintf("│   ╰ %dx (%d %s) • Rp %s\n", item.Jumlah, item.Berat, item.Satuan, FormatRupiah(item.TotalHarga)))
	}
	sb.WriteString("──────────────────\n")

	// Rincian Harga
	subtotal := 0
	for _, item := range pesanan.OrderItems {
		subtotal += item.TotalHarga
	}

	sb.WriteString("<b>Rincian Harga:</b>\n")
	sb.WriteString(fmt.Sprintf("├ Subtotal\t: Rp %s\n", FormatRupiah(subtotal)))
	sb.WriteString(fmt.Sprintf("├ Ongkos Kirim\t: Rp %s\n", FormatRupiah(pesanan.Ongkir)))
	sb.WriteString(fmt.Sprintf("╰ <b>TOTAL\t: Rp %s</b>\n", FormatRupiah(pesanan.TotalBayar)))
	sb.WriteString("──────────────────\n")

	// Metode Pembayaran
	sb.WriteString(fmt.Sprintf("<b>Metode Pembayaran:</b> %s\n", pesanan.MetodePembayaran))
	sb.WriteString("──────────────────\n")

	// Link detail
	detailURL := fmt.Sprintf("https://admin.getsayor.com/orders/%d", pesanan.ID)
	sb.WriteString(fmt.Sprintf("📝 <a href=\"%s\">LIHAT DETAIL PESANAN</a>", detailURL))

	return sb.String()
}

// FormatTelegramOrderMessage Poin membuat pesan notifikasi Telegram
func FormatTelegramOrderPoinMessage(pesanan models.Pesanan) string {
	var sb strings.Builder

	// Header
	sb.WriteString(fmt.Sprintf("🛒 <b>ORDER BARUU #%s</b>\n", pesanan.OrderId))
	sb.WriteString("──────────────────\n")

	// Pelanggan
	sb.WriteString("<b>Pelanggan:</b>\n")
	if pesanan.User.Details != nil {
		sb.WriteString(fmt.Sprintf("├ %s\n", pesanan.User.Details.Fullname))
		sb.WriteString(fmt.Sprintf("╰ %s\n", pesanan.User.Details.PhoneNumber))
	} else {
		sb.WriteString("├ Pelanggan Tidak Dikenal\n")
		sb.WriteString("╰ -\n")
	}
	sb.WriteString("──────────────────\n")

	// Produk
	sb.WriteString(fmt.Sprintf("<b>Produk (%d item):</b>\n", len(pesanan.OrderItems)))
	for i, item := range pesanan.OrderItems {
		prefix := "├"
		if i == len(pesanan.OrderItems)-1 {
			prefix = "╰"
		}
		sb.WriteString(fmt.Sprintf("%s %s\n", prefix, item.NamaProduk))
		sb.WriteString(fmt.Sprintf("│   ╰ %dx (%d %s) • Poin %s\n", item.Jumlah, item.Berat, item.Satuan, FormatRupiah(item.TotalHarga)))
	}
	sb.WriteString("──────────────────\n")

	// Rincian Harga
	subtotal := 0
	for _, item := range pesanan.OrderItems {
		subtotal += item.TotalHarga
	}

	sb.WriteString("<b>Rincian Harga:</b>\n")
	sb.WriteString(fmt.Sprintf("├ Subtotal\t: Poin %s\n", FormatRupiah(subtotal)))
	sb.WriteString(fmt.Sprintf("├ Ongkos Kirim\t: Poin %s\n", FormatRupiah(pesanan.Ongkir)))
	sb.WriteString(fmt.Sprintf("╰ <b>TOTAL\t: Poin %s</b>\n", FormatRupiah(pesanan.TotalBayar)))
	sb.WriteString("──────────────────\n")

	// Metode Pembayaran
	sb.WriteString(fmt.Sprintf("<b>Metode Pembayaran:</b> %s\n", pesanan.MetodePembayaran))
	sb.WriteString("──────────────────\n")

	// Link detail
	detailURL := fmt.Sprintf("https://admin.getsayor.com/orders/%d", pesanan.ID)
	sb.WriteString(fmt.Sprintf("📝 <a href=\"%s\">LIHAT DETAIL PESANAN</a>", detailURL))

	return sb.String()
}
