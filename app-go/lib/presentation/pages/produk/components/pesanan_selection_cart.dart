import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getsayor/cache_manager/cache_manager.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/presentation/pages/loading_page.dart';
import 'package:getsayor/presentation/pages/produk/components/adress.dart';
import 'package:getsayor/presentation/pages/produk/components/order_confirmation_cart.dart';
import 'package:getsayor/presentation/pages/profile/components/alamat_saya.dart';
import 'package:getsayor/data/services/address_service.dart';
import 'package:getsayor/data/services/pesanan_service.dart';
import 'package:intl/intl.dart';
import 'package:getsayor/data/model/cart_item.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

final currencyFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

String formatRupiah(int value) {
  return currencyFormat.format(value).replaceAll('Rp', 'Rp. ');
}

final Dio _dio = Dio();

class PaymentSelectionCart extends StatefulWidget {
  final List<CartItem> selectedProducts;
  final List<int> quantities;
  final int totalHarga;
  final int totalPoin;

  const PaymentSelectionCart({
    super.key,
    required this.selectedProducts,
    required this.quantities,
    required this.totalHarga,
    required this.totalPoin,
  });

  @override
  State<PaymentSelectionCart> createState() => _PaymentSelectionCartState();
}

class _PaymentSelectionCartState extends State<PaymentSelectionCart> {
  bool hasDefaultAddress = false;
  bool _isProcessing = false;
  late String _idempotencyKey;
  bool _isOpeningCOD = false;
  bool _isOpeningPoin = false;

  @override
  void initState() {
    super.initState();
    _idempotencyKey = const Uuid().v4(); // Generate sekali saja
  }

  Future<int?> getHargaPoin(BuildContext context) async {
    try {
      // Ambil token dari UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Kirim request dengan token di header Authorization
      final response = await _dio.get(
        '$baseUrl/settings-app/harga-poin',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Menambahkan token ke header
          },
        ),
      );

      // Mengecek apakah status code dari response adalah 200 (OK)
      if (response.statusCode == 200) {
        debugPrint(
            'Response data: ${response.data}'); // Debug untuk memeriksa data yang diterima
        return response.data['hargaPoin'];
      } else {
        debugPrint('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  void bayarDenganCODCart(context, CartItem item) async {
    setState(() => _isOpeningCOD = true); // Mulai loading

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    // int ongkir = 10000;

    final address = await AddressService().getDefaultAddress(context, userId);

    // Update state untuk mengecek keberadaan alamat
    setState(() {
      hasDefaultAddress = address != null;
    });

    int ongkir = address?.shippingRate?.price ?? 0; // Default 0 jika null

    int totalBayar = widget.totalHarga + ongkir;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pembayaran COD',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Color(0xFF1F2131),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Harga Produk",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF1F2131),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    formatRupiah(widget.totalHarga),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF1F2131),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ongkir",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF1F2131),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    formatRupiah(ongkir),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF1F2131),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xFFE2E3E6), thickness: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Bayar",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF1F2131),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    formatRupiah(totalBayar),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF1F2131),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0x23FFC875),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFFFF9A01),
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Pastikan alamat Anda sudah sesuai!',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Color(0xFFFF9A01),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0XFFF5F5F5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Shipping Address',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddressPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF74B11A),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AddressWidget(userId: userId ?? 0),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_isProcessing || !hasDefaultAddress)
                    ? null
                    : () async {
                        setState(() => _isProcessing = true);

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          useRootNavigator: true,
                          builder: (context) => const LoadingPage(),
                        );

                        try {
                          int id = widget.selectedProducts.first.productItem.id;
                          List<CartItem> cartItems = widget.selectedProducts;
                          String invoiceNumber =
                              'INV-${DateTime.now().millisecondsSinceEpoch}';

                          List<Map<String, dynamic>> items =
                              cartItems.map((item) {
                            int totalHarga =
                                item.productItem.hargaRp * item.quantity;

                            //hitung berat
                            int berat = item.quantity * item.productItem.jumlah;
                            print("Jumlah: ${item.productItem.jumlah}");

                            return {
                              'productId': item.productItem.id,
                              'namaProduk': item.productItem.nameProduk,
                              'harga': item.productItem.hargaRp,
                              'jumlah': item.quantity,
                              'berat': berat,
                              'satuan': item.productItem.satuan,
                              'totalHarga': totalHarga,
                            };
                          }).toList();

                          print(
                              "Product ID: ${item.productItem.id}, Name: ${item.productItem.nameProduk}");

                          print("Items: $items");

                          bool berhasil =
                              await PesananService().bayarDenganCODCart(
                            context,
                            id,
                            widget.totalHarga,
                            ongkir,
                            totalBayar,
                            invoiceNumber,
                            items,
                            _idempotencyKey,
                          );

                          if (berhasil && context.mounted) {
                            print("${widget.quantities}");
                            Navigator.of(context, rootNavigator: true).pop();
                            Navigator.of(context, rootNavigator: true).pop();
                            Navigator.of(context, rootNavigator: true).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (_, animation, secondaryAnimation) =>
                                        OrderConfirmationCartPage(
                                  namaProduk:
                                      widget.selectedProducts.map((item) {
                                    return '${item.productItem.nameProduk} (${item.productItem.jumlah} ${item.productItem.satuan == "Gram" ? "gr" : item.productItem.satuan == "Kilogram" ? "kg" : item.productItem.satuan == "Biji" ? "biji" : item.productItem.satuan == "Buah" ? "buah" : item.productItem.satuan == "Pcs" ? "pcs" : item.productItem.satuan})';
                                  }).toList(),
                                  jumlah: widget.quantities, // Kirim quantities
                                  berat: widget.selectedProducts
                                      .map((item) =>
                                          item.quantity *
                                          item.productItem.jumlah)
                                      .toList(),
                                  satuan: widget.selectedProducts
                                      .map((item) => item.productItem
                                          .satuan) // Ambil satuan per produk
                                      .toList(),
                                  hargaProduk:
                                      widget.selectedProducts.map((item) {
                                    return formatRupiah(
                                        item.productItem.hargaRp);
                                  }).toList(),
                                  totalHarga: formatRupiah(widget.totalHarga),
                                  ongkir: formatRupiah(ongkir),
                                  totalBayar: formatRupiah(totalBayar),
                                  invoiceNumber: invoiceNumber,
                                  orderDate: DateTime.now().toIso8601String(),
                                  metodePembayaran: 'COD',
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint('Payment error: $e');
                          if (context.mounted) {
                            String invoiceNumber =
                                'INV-${DateTime.now().millisecondsSinceEpoch}';
                            Navigator.of(context, rootNavigator: true).pop();
                            if (e.toString().contains("already processed")) {
                              Navigator.of(context, rootNavigator: true).push(
                                PageRouteBuilder(
                                  pageBuilder:
                                      (_, animation, secondaryAnimation) =>
                                          OrderConfirmationCartPage(
                                    namaProduk:
                                        widget.selectedProducts.map((item) {
                                      return '${item.productItem.nameProduk} (${item.productItem.jumlah} ${item.productItem.satuan == "Gram" ? "gr" : item.productItem.satuan == "Kilogram" ? "kg" : item.productItem.satuan == "Biji" ? "biji" : item.productItem.satuan == "Buah" ? "buah" : item.productItem.satuan == "Pcs" ? "pcs" : item.productItem.satuan})';
                                    }).toList(),
                                    jumlah:
                                        widget.quantities, // Kirim quantities
                                    berat: widget.selectedProducts
                                        .map((item) =>
                                            item.quantity *
                                            item.productItem.jumlah)
                                        .toList(),
                                    satuan: widget.selectedProducts
                                        .map((item) => item.productItem
                                            .satuan) // Ambil satuan per produk
                                        .toList(),
                                    hargaProduk:
                                        widget.selectedProducts.map((item) {
                                      return formatRupiah(
                                          item.productItem.hargaRp);
                                    }).toList(),
                                    totalHarga: formatRupiah(widget.totalHarga),
                                    ongkir: formatRupiah(ongkir),
                                    totalBayar: formatRupiah(totalBayar),
                                    invoiceNumber: invoiceNumber,
                                    orderDate: DateTime.now().toIso8601String(),
                                    metodePembayaran: 'COD',
                                  ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: e.toString(),
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.TOP,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 14.0,
                              );
                            }
                          }
                        } finally {
                          setState(() => _isProcessing = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF74B11A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Pesan Sekarang',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );

    setState(() => _isOpeningCOD = false);
  }

  void bayarDenganPoinCart(context, CartItem item) async {
    setState(() => _isOpeningPoin = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;

    final address = await AddressService().getDefaultAddress(context, userId);

    // Update state untuk mengecek keberadaan alamat
    setState(() {
      hasDefaultAddress = address != null;
    });

    // Ambil harga ongkir dari shippingRate dan bulatkan ke atas (ceil)
    int ongkir = (address?.shippingRate?.price ?? 0);
    int ongkirDalamPoin = (ongkir / 10).ceil();
    int totalBayar = widget.totalPoin + ongkirDalamPoin;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pembayaran POIN',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Color(0xFF1F2131),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Harga Produk",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF1F2131),
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/poin.png',
                        width: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        numberFormat.format(widget.totalPoin),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF1F2131),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ongkir",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF1F2131),
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/poin.png',
                        width: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        numberFormat.format(ongkirDalamPoin),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF1F2131),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xFFE2E3E6), thickness: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Bayar",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF1F2131),
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/poin.png',
                        width: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        numberFormat.format(totalBayar),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF1F2131),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0x23FFC875),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFFFF9A01),
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Pastikan alamat Anda sudah sesuai!',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Color(0xFFFF9A01),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0XFFF5F5F5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Shipping Address',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddressPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF74B11A),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AddressWidget(userId: userId ?? 0),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_isProcessing || !hasDefaultAddress)
                    ? null
                    : () async {
                        setState(() => _isProcessing = true);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          useRootNavigator: true,
                          builder: (context) => const LoadingPage(),
                        );

                        try {
                          int id = widget.selectedProducts.first.productItem.id;
                          List<CartItem> cartItems = widget.selectedProducts;
                          String invoiceNumber =
                              'INV-${DateTime.now().millisecondsSinceEpoch}';

                          List<Map<String, dynamic>> items =
                              cartItems.map((item) {
                            int totalHarga =
                                item.productItem.hargaPoin * item.quantity;

                            int berat = item.quantity * item.productItem.jumlah;
                            print("Jumlah: ${item.productItem.jumlah}");

                            return {
                              'productId': item.productItem.id,
                              'namaProduk': item.productItem.nameProduk,
                              'harga': item.productItem.hargaPoin,
                              'jumlah': item.quantity,
                              'berat': berat,
                              'satuan': item.productItem.satuan,
                              'totalHarga': totalHarga,
                            };
                          }).toList();

                          // Cek apakah poin cukup terlebih dahulu
                          bool berhasil =
                              await PesananService().bayarDenganPoinCart(
                            context,
                            id,
                            widget.totalPoin,
                            ongkirDalamPoin,
                            totalBayar,
                            invoiceNumber,
                            items,
                            _idempotencyKey,
                          );

                          if (berhasil && context.mounted) {
                            // Tutup bottom sheet
                            Navigator.of(context, rootNavigator: true);
                            Navigator.of(context, rootNavigator: true).pop();
                            Navigator.of(context, rootNavigator: true).pop();
                            Navigator.of(context, rootNavigator: true).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (_, animation, secondaryAnimation) =>
                                        OrderConfirmationCartPage(
                                  namaProduk:
                                      widget.selectedProducts.map((item) {
                                    return '${item.productItem.nameProduk} (${item.productItem.jumlah} ${item.productItem.satuan == "Kilogram" ? "kg" : item.productItem.satuan == "Gram" ? "gr" : item.productItem.satuan == "Biji" ? "biji" : item.productItem.satuan == "Buah" ? "buah" : item.productItem.satuan == "Pcs" ? "pcs" : item.productItem.satuan})';
                                  }).toList(),
                                  jumlah: widget.quantities,
                                  berat: widget.selectedProducts
                                      .map((item) =>
                                          item.quantity *
                                          item.productItem.jumlah)
                                      .toList(),
                                  satuan: widget.selectedProducts
                                      .map((item) => item.productItem
                                          .satuan) // Ambil satuan per produk
                                      .toList(),
                                  hargaProduk:
                                      widget.selectedProducts.map((item) {
                                    return '${item.productItem.hargaPoin}';
                                  }).toList(),
                                  totalHarga: '${widget.totalPoin}',
                                  ongkir: '$ongkirDalamPoin',
                                  totalBayar: '$totalBayar',
                                  invoiceNumber: invoiceNumber,
                                  orderDate: DateTime.now().toIso8601String(),
                                  metodePembayaran: 'Poin',
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          }
                        } catch (e) {
                          String invoiceNumber =
                              'INV-${DateTime.now().millisecondsSinceEpoch}';
                          debugPrint('Payment error: $e');
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pop();

                            if (e.toString().contains("already processed") ||
                                e.toString().contains("Timeout tetapi order")) {
                              Navigator.of(context, rootNavigator: true).push(
                                PageRouteBuilder(
                                  pageBuilder:
                                      (_, animation, secondaryAnimation) =>
                                          OrderConfirmationCartPage(
                                    namaProduk:
                                        widget.selectedProducts.map((item) {
                                      return '${item.productItem.nameProduk} (${item.productItem.jumlah} ${item.productItem.satuan == "Kilogram" ? "kg" : item.productItem.satuan == "Gram" ? "gr" : item.productItem.satuan == "Biji" ? "biji" : item.productItem.satuan == "Buah" ? "buah" : item.productItem.satuan == "Pcs" ? "pcs" : item.productItem.satuan})';
                                    }).toList(),
                                    jumlah: widget.quantities,
                                    berat: widget.selectedProducts
                                        .map((item) =>
                                            item.quantity *
                                            item.productItem.jumlah)
                                        .toList(),
                                    satuan: widget.selectedProducts
                                        .map((item) => item.productItem
                                            .satuan) // Ambil satuan per produk
                                        .toList(),
                                    hargaProduk:
                                        widget.selectedProducts.map((item) {
                                      return '${item.productItem.hargaPoin}';
                                    }).toList(),
                                    totalHarga: '${widget.totalPoin}',
                                    ongkir: '$ongkirDalamPoin',
                                    totalBayar: '$totalBayar',
                                    invoiceNumber: invoiceNumber,
                                    orderDate: DateTime.now().toIso8601String(),
                                    metodePembayaran: 'Poin',
                                  ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: e.toString(),
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.TOP,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 14.0,
                              );
                            }
                          }
                        } finally {
                          setState(() => _isProcessing = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF74B11A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Pesan Sekarang',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );

    setState(() => _isOpeningPoin = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text(
          'Payment',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2131),
            fontSize: 16,
          ),
        ),
      ),
      backgroundColor: const Color(0XFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 200 - 60,
              child: ListView.builder(
                itemCount: widget.selectedProducts.length,
                itemBuilder: (context, index) {
                  final item = widget.selectedProducts[index];
                  final quantity = widget.quantities[index];
                  final imageUrl = (item.productItem.image != null &&
                          item.productItem.image!.startsWith('http'))
                      ? item.productItem.image!
                      : '$baseUrlStatic/${item.productItem.image ?? 'placeholder.png'}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        Container(
                          width: 70,
                          height: 70,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F1F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              memCacheHeight: 150,
                              memCacheWidth: 150,
                              maxHeightDiskCache: 150,
                              maxWidthDiskCache: 150,
                              fadeInDuration: Duration.zero,
                              placeholder: (context, url) =>
                                  FutureBuilder<FileInfo?>(
                                future: AppCacheManager().getFileFromCache(url),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data!.file.existsSync()) {
                                    return Image.file(
                                      snapshot.data!.file,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Color(0xFF74B11A),
                                    ),
                                  );
                                },
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/placeholder.png',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Kolom untuk nameProduk, hargaRp, dan hargaPoin
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.productItem.nameProduk} (${item.productItem.jumlah} ${item.productItem.satuan == 'Gram' ? 'gr' : item.productItem.satuan == 'Kilogram' ? 'kg' : item.productItem.satuan == 'Biji' ? 'biji' : item.productItem.satuan})',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/poin.png',
                                        width: 16,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        numberFormat
                                            .format(item.productItem.hargaPoin),
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Color(0xFF1F2131),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    currencyFormat
                                        .format(item.productItem.hargaRp),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              // Teks jumlah di sebelah kanan
                              Text(
                                'x${quantity}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      ]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Poin",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/poin.png',
                          width: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          numberFormat.format(widget.totalPoin),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Rupiah",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formatRupiah(
                          widget.totalHarga), // Total harga dalam Rupiah
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Buttons layout with Row for left and right alignment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Button to choose COD on the left
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isOpeningCOD || _isOpeningPoin
                        ? null
                        : () => bayarDenganCODCart(
                            context, widget.selectedProducts.first),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F2131),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isOpeningCOD
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delivery_dining_outlined,
                                color: Color(0xFFFFFFFF),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'COD',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(width: 10),

                // Button for paying with points on the right
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isOpeningCOD || _isOpeningPoin
                        ? null
                        : () => bayarDenganPoinCart(
                            context, widget.selectedProducts.first),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF589400),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isOpeningPoin
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.redeem_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Poin',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
