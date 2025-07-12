import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/data/model/pesanan_model.dart';
import 'package:getsayor/presentation/pages/produk/components/order_confirmation.dart';
import 'package:getsayor/presentation/pages/produk/components/order_confirmation_cart.dart';
import 'package:getsayor/presentation/pages/produk/components/order_page.dart';

import 'package:intl/intl.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");
final currencyFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

String formatRupiah(int value) {
  return currencyFormat.format(value).replaceAll('Rp', 'Rp. ');
}

class OrderDetailPage extends StatelessWidget {
  final PesananModel pesanan;

  const OrderDetailPage({super.key, required this.pesanan});

  void _showInvoice(BuildContext context) {
    // Calculate shipping cost
    int totalProductPrice =
        pesanan.items.fold(0, (sum, item) => sum + (item.harga * item.jumlah));
    int shippingCost = pesanan.totalBayar - totalProductPrice;

    if (pesanan.items.length == 1) {
      // Single product invoice
      final item = pesanan.items.first;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationPage(
            namaProduk: item.namaProduk,
            jumlah: item.jumlah.toString(),
            beratNormal: item.berat,
            satuan: item.satuan,
            hargaProduk: pesanan.hargaRp != null
                ? formatRupiah(item.harga)
                : item.harga.toString(),
            ongkir: pesanan.hargaRp != null
                ? formatRupiah(shippingCost)
                : shippingCost.toString(),
            totalBayar: pesanan.hargaRp != null
                ? formatRupiah(item.harga * item.jumlah)
                : (item.harga * item.jumlah).toString(),
            totalBayarSemua: pesanan.hargaRp != null
                ? formatRupiah(pesanan.totalBayar)
                : pesanan.totalBayar.toString(),
            invoiceNumber: pesanan.orderId,
            orderDate: pesanan.createdAt,
          ),
        ),
      );
    } else {
      // Multiple products invoice
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationCartPage(
            namaProduk: pesanan.items.map((e) => e.namaProduk).toList(),
            jumlah: pesanan.items.map((e) => e.jumlah).toList(),
            berat: pesanan.items.map((e) => e.berat).toList(),
            hargaProduk: pesanan.items
                .map((e) => pesanan.hargaRp != null
                    ? formatRupiah(e.harga)
                    : e.harga.toString())
                .toList(),
            satuan: pesanan.items.map((e) => e.satuan).toList(),
            ongkir: pesanan.hargaRp != null
                ? formatRupiah(shippingCost)
                : shippingCost.toString(),
            totalHarga: pesanan.hargaRp != null
                ? formatRupiah(totalProductPrice)
                : totalProductPrice.toString(),
            totalBayar: pesanan.hargaRp != null
                ? formatRupiah(pesanan.totalBayar)
                : pesanan.totalBayar.toString(),
            invoiceNumber: pesanan.orderId,
            orderDate: pesanan.createdAt,
          ),
        ),
      );
    }
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required String value,
    required Color statusColor,
    bool isStatus = false,
    bool isPayment = false,
  }) {
    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: statusColor,
          ),
        ),
        const SizedBox(width: 12),

        // Label
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
        ),

        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: isPayment && pesanan.paymentStatus == 'unpaid'
                ? Colors.white
                : statusColor,
            borderRadius: BorderRadius.circular(12),
            border: isPayment && pesanan.paymentStatus == 'unpaid'
                ? Border.all(color: statusColor, width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status indicator dot
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isPayment && pesanan.paymentStatus == 'unpaid'
                      ? statusColor
                      : Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPayment && pesanan.paymentStatus == 'unpaid'
                      ? statusColor
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B); // Amber
      case 'confirmed':
        return const Color(0xFF10B981); // Emerald
      case 'processed':
        return const Color(0xFF3B82F6); // Blue
      case 'out-for-delivery':
        return const Color(0xFF8B5CF6); // Purple
      case 'delivered':
        return const Color(0xFF06B6D4); // Cyan
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'unpaid':
        return const Color(0xFFEF4444); // Red
      case 'paid':
        return const Color(0xFF10B981); // Emerald
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        // automaticallyImplyLeading: false,
        title: Text(
          'Detail Pesanan #${pesanan.orderId}',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        // centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0XFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFORMASI STATUS PESANAN
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.assignment_outlined,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Informasi Pesanan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Status Pesanan
                    _buildStatusRow(
                      icon: Icons.local_shipping_outlined,
                      label: 'Status Pesanan',
                      value: OrderPageState.statusMap[pesanan.status] ??
                          pesanan.status,
                      statusColor: _getOrderStatusColor(pesanan.status),
                      isStatus: true,
                    ),

                    const SizedBox(height: 20),

                    // Status Pembayaran
                    _buildStatusRow(
                      icon: Icons.payment_outlined,
                      label: 'Status Pembayaran',
                      value: OrderPageState
                              .paymentStatusMap[pesanan.paymentStatus] ??
                          pesanan.paymentStatus,
                      statusColor:
                          _getPaymentStatusColor(pesanan.paymentStatus),
                      isPayment: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // DAFTAR SEMUA PRODUK
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produk Dipesan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: pesanan.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 65,
                                height: 65,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0XFFF5F5F5),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: '$baseUrlStatic/${item.image}',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.namaProduk,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            if (pesanan.hargaRp == null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5),
                                                child: Image.asset(
                                                  'assets/images/poin.png',
                                                  height: 16,
                                                  width: 16,
                                                ),
                                              ),
                                            Text(
                                              pesanan.hargaRp != null
                                                  ? formatRupiah(item.harga)
                                                  : '${numberFormat.format(item.harga)} Poin',
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                color: Colors.grey,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${item.berat} ${item.satuan.toLowerCase() == 'kilogram' ? 'kg' : item.satuan.toLowerCase() == 'gram' ? 'gr' : item.satuan}',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const Divider(
                      color: Color(0xFFF0F1F5),
                      thickness: 1,
                    ),
                    const SizedBox(height: 10),

                    // TOTAL PEMBAYARAN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran:',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            if (pesanan.hargaRp == null)
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Image.asset(
                                  'assets/images/poin.png',
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                            Text(
                              pesanan.hargaRp != null
                                  ? formatRupiah(pesanan.totalBayar)
                                  : '${numberFormat.format(pesanan.totalBayar)} Poin',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF74B11A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // TOMBOL LIHAT INVOICE
                    Center(
                        child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF74B11A), Color(0xFFABCF51)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          onPressed: () => _showInvoice(context),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Lihat Invoice',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
