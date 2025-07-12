import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getsayor/data/model/poin_model.dart';
import 'package:getsayor/data/services/navigation_service.dart';
import 'package:getsayor/data/services/topup_service.dart';
import 'package:getsayor/data/services/poin_service.dart';
import 'package:getsayor/presentation/pages/loading_page.dart';
import 'package:getsayor/presentation/pages/top_up/components/pendingTransaction.dart';
import 'package:getsayor/presentation/pages/top_up/components/success_page.dart';
import 'package:intl/intl.dart';
import 'package:onepref/onepref.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

final formattedDate = DateFormat("dd MMMM yyyy - HH:mm", "id_ID");

class BuyPoints extends StatefulWidget {
  const BuyPoints({super.key});

  static String routeName = "/buypoints";

  @override
  State<BuyPoints> createState() => _BuyPointsState();
}

class _BuyPointsState extends State<BuyPoints> {
  List<Poin> poinList = [];
  List<ProductDetails> _products = [];
  late final IApEngine iApEngine = IApEngine();
  int reward = 0;
  bool isLoading = false;
  bool _isRefreshing = true;
  final Set<String> _completedBackendPurchaseIds = {};
  bool _isPurchaseHandlerLocked = false;
  final Set<String> _completedPurchases = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReward();
    _loadPoins();
    _retryPendingTransactions();

    iApEngine.inAppPurchase.restorePurchases();

    iApEngine.inAppPurchase.purchaseStream.listen((purchases) {
      _handlePurchases(purchases);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    if (_isPurchaseHandlerLocked) return;

    _isPurchaseHandlerLocked = true;
    debugPrint("=== LOCK ACQUIRED ===");

    try {
      final pending = await PendingTransactionStorage.getPendingTransactions();
      final pendingIds = pending.map((t) => t.purchaseId).toSet();

// Modifikasi kondisi newPurchases
      final newPurchases = purchases
          .where((p) =>
              p.purchaseID != null &&
              !_completedPurchases.contains(p.purchaseID!) &&
              !pendingIds.contains(
                  p.purchaseID!) && // Hindari duplikasi dengan pending
              p.status == PurchaseStatus.purchased)
          .toList();

      if (newPurchases.isEmpty) return;

      debugPrint("Processing ${newPurchases.length} purchases");

      // Kelompokkan berdasarkan productID dan ambil yang terbaru
      final Map<String, List<PurchaseDetails>> grouped = {};
      for (final p in newPurchases) {
        grouped.putIfAbsent(p.productID, () => []).add(p);
      }

      for (final productId in grouped.keys) {
        final productPurchases = grouped[productId]!;

        // Urutkan dari yang terbaru
        productPurchases.sort((a, b) {
          final aDate = _parseTransactionDate(a.transactionDate);
          final bDate = _parseTransactionDate(b.transactionDate);
          return bDate.compareTo(aDate);
        });

        final purchase = productPurchases.first;

        // Tandai SEMUA pembelian dalam grup ini sebagai selesai
        for (final p in productPurchases) {
          _completedPurchases.add(p.purchaseID!);
          debugPrint("Marked as completed: ${p.purchaseID}");
        }

        // Proses hanya pembelian terbaru
        await _processPurchase(purchase);
      }
    } catch (e) {
      debugPrint("Error in purchase handling: $e");
    } finally {
      _isPurchaseHandlerLocked = false;
      debugPrint("=== LOCK RELEASED ===");
    }
  }

  DateTime _parseTransactionDate(String? dateString) {
    if (dateString == null) return DateTime(0);
    return DateTime.tryParse(dateString) ?? DateTime(0);
  }

  Map<K, List<T>> groupBy<T, K>(Iterable<T> items, K Function(T) keyFunction) {
    final map = <K, List<T>>{};
    for (final item in items) {
      final key = keyFunction(item);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  Future<void> _loadReward() async {
    reward = OnePref.getInt("points") ?? 0;
    setState(() {});
  }

  Future<void> _loadPoins() async {
    try {
      setState(() {
        _isRefreshing = true;
        _errorMessage = null; // Reset error saat memuat ulang
      });

      final poins = await PoinService().fetchPoin(context);
      if (mounted) {
        setState(() => poinList = poins);
      }
      await _getProducts();
    } catch (e) {
      debugPrint("Error loading points: $e");
      if (mounted) {
        setState(() {
          _errorMessage =
              'Gagal memuat produk. Pastikan koneksi internet Anda stabil.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _getProducts() async {
    if (poinList.isEmpty) return;

    final productIds = poinList
        .map((poin) => [
              poin.productId,
              if (poin.promoProductId != null) poin.promoProductId
            ])
        .expand((id) => id)
        .whereType<String>()
        .toList();

    if (await iApEngine.getIsAvailable()) {
      try {
        final response = await iApEngine.queryProducts(productIds);
        if (mounted) {
          setState(() => _products = response.productDetails);
        }
      } catch (e) {
        debugPrint("Error fetching products: $e");
        if (mounted) {
          setState(() {
            _errorMessage = 'Gagal memuat detail produk. Silakan coba lagi.';
          });
        }
      }
    }
  }

  Future<void> _handleRefresh() async {
    if (mounted) {
      setState(() {
        _isRefreshing = true;
        _errorMessage = null; // Reset error saat refresh
      });
    }
    await _loadPoins();
    await _loadReward();
    await _retryPendingTransactions();
  }

  ProductDetails? _getProduct(String? productId) {
    if (productId == null) return null;
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _processPurchase(PurchaseDetails purchase) async {
    try {
      // [0] Pastikan status masih valid sebelum proses
      if (purchase.status != PurchaseStatus.purchased) {
        debugPrint("Purchase status invalid: ${purchase.status}");
        return;
      }

      // [1] Cek duplikasi SEBELUM memulai loading
      if (_completedBackendPurchaseIds.contains(purchase.purchaseID!)) {
        debugPrint(
            "Purchase already processed with backend: ${purchase.purchaseID}");
        return;
      }

      if (mounted) {
        setState(() => isLoading = true);
      }

      final purchasedPoin = poinList.firstWhere(
        (poin) =>
            poin.productId == purchase.productID ||
            (poin.promoProductId != null &&
                poin.promoProductId == purchase.productID),
        orElse: () => Poin(id: 0, poin: 0, productId: ""),
      );

      if (purchasedPoin.poin > 0) {
        final newReward = reward + purchasedPoin.poin;
        OnePref.setInt("points", newReward);

        if (mounted) {
          setState(() => reward = newReward);
        }

        ProductDetails? purchasedProduct = _getProduct(purchase.productID);
        if (purchasedProduct == null) {
          throw Exception("Product details not found");
        }

        ProductDetails? mainProduct = _getProduct(purchasedPoin.productId);
        String displayPrice = purchasedProduct.price;
        String? originalPrice;

        if (purchasedPoin.promoProductId == purchase.productID &&
            mainProduct != null) {
          originalPrice = mainProduct.price;
        }

        final invoiceNumber =
            "INV-${DateFormat('yyyyMMdd').format(DateTime.now())}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

        try {
          // [1] Cek token dari SharedPreferences langsung
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token') ?? '';
          debugPrint("Token from SharedPreferences: $token");

          if (token.isEmpty) {
            throw TopUpException('User not authenticated', retryable: false);
          }

          // [2] Dapatkan userId dari SharedPreferences
          final userId = prefs.getString('userId') ?? '';
          debugPrint("UserID from SharedPreferences: $userId");

          if (userId.isEmpty) {
            throw TopUpException('User ID not found', retryable: false);
          }

          // [2] Tandai SEBELUM mengirim ke backend
          _completedBackendPurchaseIds.add(purchase.purchaseID!);

          await _sendTopUpToBackend(
            token: token,
            userId: userId,
            points: purchasedPoin.poin,
            price: displayPrice,
            purchaseId: purchase.purchaseID!,
            invoiceNumber: invoiceNumber,
          );
        } catch (e) {
          // [3] Jika gagal, hapus dari daftar agar bisa dicoba ulang
          _completedBackendPurchaseIds.remove(purchase.purchaseID!);
          debugPrint("Warning: Top-up submission had issues: $e");
        } finally {
          await iApEngine.inAppPurchase.completePurchase(purchase);
        }

        // Ganti navigasi dengan menggunakan navigatorKey
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => SuccessPage(
                points: purchasedPoin.poin,
                price: displayPrice,
                originalPrice: originalPrice,
                date: DateTime.now(),
                invoiceNumber: invoiceNumber,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error processing purchase: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _retryPendingTransactions() async {
    final pendingTransactions =
        await PendingTransactionStorage.getPendingTransactions();

    final token = OnePref.getString('token') ?? '';
    final userId = OnePref.getString('userId') ?? '';

    // Tambahkan pengecekan
    if (token.isEmpty || userId.isEmpty) {
      debugPrint("Skipping retry: User not authenticated");
      return;
    }

    for (final transaction in pendingTransactions) {
      try {
        await _sendTopUpToBackend(
          token: token,
          userId: userId,
          points: transaction.points,
          price: transaction.price,
          purchaseId: transaction.purchaseId,
          invoiceNumber: transaction.invoiceNumber,
          isRetry: true,
        );
      } catch (e) {
        debugPrint("Retry failed for ${transaction.purchaseId}: $e");
      }
    }
  }

  Future<void> _sendTopUpToBackend({
    required String token,
    required String userId,
    required int points,
    required String price,
    required String purchaseId,
    required String invoiceNumber,
    bool isRetry = false,
  }) async {
    try {
      debugPrint("=== START SEND TOPUP ===");
      debugPrint("Token: $token");
      debugPrint("UserID: $userId");
      debugPrint("Points: $points");
      debugPrint("Price: $price");
      debugPrint("PurchaseID: $purchaseId");
      debugPrint("Invoice: $invoiceNumber");

      final priceValue = _parsePrice(price);
      debugPrint("Parsed Price: $priceValue");

      await TopUpPoinService().postTopUpData(
        token,
        userId,
        points,
        priceValue,
        DateTime.now(),
        "In-App Purchase",
        purchaseId,
        invoiceNumber,
      );

      // Hapus dari pending jika ini percobaan ulang
      if (isRetry) {
        debugPrint("RETRYING pending transaction: $purchaseId");
        await PendingTransactionStorage.removePendingTransaction(purchaseId);
        debugPrint("Removed from pending: $purchaseId");
      }

      debugPrint("Top-up backend success!");
    } catch (e) {
      debugPrint("Top-up backend error: $e");

      String userMessage = 'Top Up Gagal';
      bool willRetry = false;
      Color bgColor = Colors.red;

      if (e is TopUpException) {
        userMessage += ', ${e.message}';
        willRetry = e.retryable;
        bgColor = e.retryable ? Colors.orange : Colors.red;
      } else {
        userMessage += ', Terjadi kesalahan tak terduga';
      }

      if (willRetry && !isRetry) {
        userMessage += '\nPoin akan ditambahkan secara otomatis nanti';

        await PendingTransactionStorage.addPendingTransaction(
          PendingTransaction(
            purchaseId: purchaseId,
            points: points,
            price: price,
            date: DateTime.now(),
            invoiceNumber: invoiceNumber,
          ),
        );
      }

      if (!isRetry) {
        Fluttertoast.showToast(
          msg: userMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: bgColor,
          textColor: Colors.white,
          fontSize: 16.0,
          timeInSecForIosWeb: 5,
        );
      }
    }
  }

  int _parsePrice(String priceStr) {
    try {
      // Handle currency symbols and formatting
      priceStr = priceStr.replaceAll(RegExp(r'[^0-9.,]'), '');

      // Handle different decimal separators
      if (priceStr.contains(',') && priceStr.contains('.')) {
        // Format like 1.000,00 or 1,000.00
        final lastComma = priceStr.lastIndexOf(',');
        final lastDot = priceStr.lastIndexOf('.');

        if (lastComma > lastDot) {
          // Comma is decimal separator (1.000,00)
          priceStr = priceStr.replaceAll('.', '').replaceAll(',', '.');
        } else {
          // Dot is decimal separator (1,000.00)
          priceStr = priceStr.replaceAll(',', '');
        }
      } else if (priceStr.contains(',')) {
        // Replace comma with dot for decimal
        priceStr = priceStr.replaceAll(',', '.');
      }

      // Parse to double then convert to integer (cents)
      final value = double.tryParse(priceStr) ?? 0;
      return (value * 100).toInt();
    } catch (e) {
      debugPrint("Price parsing error: $e");
      return 0;
    }
  }

  bool _isDescriptionMatchesPoin(String description, int poin) {
    return description.contains(poin.toString());
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 20,
                      width: 120,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 16,
                      width: 100,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 24,
                width: 70,
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no-internet.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Produk',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Terjadi kesalahan yang tidak diketahui',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 180, // Lebar yang lebih kecil
              child: ElevatedButton.icon(
                onPressed: _handleRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopUpInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header with icon
                  const Center(
                    child: Text(
                      'Cara Top Up Poin',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Ikuti langkah-langkah berikut untuk melakukan top up poin:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Steps
                  ..._buildSteps(),

                  const SizedBox(height: 32),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F80ED),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Mengerti',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildSteps() {
    final steps = [
      {
        'icon': Icons.shopping_cart_outlined,
        'title': 'Pilih Paket Poin',
        'description': 'Pilih paket poin yang sesuai dengan kebutuhan Anda',
      },
      {
        'icon': Icons.payment_outlined,
        'title': 'Lakukan Pembayaran',
        'description':
            'Tekan tombol "Top Up" dan lakukan pembayaran melalui Google Play Billing',
      },
      {
        'icon': Icons.verified_outlined,
        'title': 'Konfirmasi Pembayaran',
        'description': 'Pembayaran akan diproses secara otomatis dan aman',
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'title': 'Poin Ditambahkan',
        'description':
            'Poin akan langsung ditambahkan ke akun Anda setelah pembayaran berhasil',
      },
      {
        'icon': Icons.refresh_outlined,
        'title': 'Pemulihan Otomatis',
        'description':
            'Jika terjadi gangguan, poin akan ditambahkan otomatis saat Anda kembali ke halaman Top Up',
      },
    ];

    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      final isLast = index == steps.length - 1;

      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F80ED).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    step['icon'] as IconData,
                    color: const Color(0xFF2F80ED),
                    size: 20,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 30,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Step content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['title'] as String,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['description'] as String,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Top Up Poin',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2131),
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF1F2131)),
            onPressed: _showTopUpInfo,
          ),
        ],
      ),
      backgroundColor: const Color(0XFFF5F5F5),
      body: Stack(
        children: [
          if (_errorMessage != null)
            _buildErrorWidget()
          else
            RefreshIndicator(
              onRefresh: _handleRefresh,
              color: const Color(0xFF74B11A),
              backgroundColor: Colors.white,
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount:
                    _isRefreshing || poinList.isEmpty ? 7 : poinList.length,
                itemBuilder: (context, index) {
                  // Show shimmer during initial load or refresh
                  if (_isRefreshing || poinList.isEmpty) {
                    return _buildShimmerCard();
                  }

                  final poin = poinList[index];
                  final mainProduct = _getProduct(poin.productId);
                  final promoProduct = _getProduct(poin.promoProductId);
                  final displayProduct = promoProduct ?? mainProduct;
                  final hasPromo = promoProduct != null;

                  bool isConsistent = displayProduct != null &&
                      _isDescriptionMatchesPoin(
                          displayProduct.description, poin.poin);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/grid_topup.png'),
                        fit: BoxFit.cover,
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: hasPromo
                                      ? const Color(0x47FFD058)
                                      : const Color(0x486CB1FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Image.asset('assets/images/poin.png',
                                      width: 42),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (displayProduct != null) ...[
                                      Text(
                                        "${numberFormat.format(int.parse(displayProduct.description))} Poin",
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F2131),
                                        ),
                                      ),
                                      if (!isConsistent)
                                        const SizedBox(height: 4),
                                      if (!isConsistent)
                                        Text(
                                          "⚠️ Deskripsi tidak sesuai jumlah poin",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            color: Colors.red[400],
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (hasPromo && mainProduct != null)
                                    Text(
                                      mainProduct.price,
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Color(0xFF6A6C7B),
                                        fontSize: 12,
                                      ),
                                    ),
                                  if (hasPromo && mainProduct != null)
                                    const SizedBox(height: 0),
                                  Text(
                                    displayProduct?.price ?? "Loading...",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: hasPromo
                                          ? const Color(0xFF27AE60)
                                          : const Color(0xFF1F2131),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 102,
                          bottom: 16,
                          child: hasPromo
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF27AE60)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "Special Offer",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Color(0xFF27AE60),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "Regular Offer",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Color(0xFF6A6C7B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: InkWell(
                            onTap: displayProduct != null && !isLoading
                                ? () => iApEngine.handlePurchase(
                                      productDetails: displayProduct,
                                      pointAmount: poin.poin,
                                    )
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F80ED),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Top Up",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (isLoading) const LoadingPage()
        ],
      ),
    );
  }
}

class IApEngine {
  final InAppPurchase inAppPurchase = InAppPurchase.instance;

  Future<bool> getIsAvailable() async => await inAppPurchase.isAvailable();

  Future<ProductDetailsResponse> queryProducts(List<String> productIds) async {
    return await inAppPurchase.queryProductDetails(productIds.toSet());
  }

  Future<void> handlePurchase({
    required ProductDetails productDetails,
    required int pointAmount,
  }) async {
    late PurchaseParam purchaseParam;

    if (Platform.isAndroid) {
      purchaseParam = GooglePlayPurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
      );
    } else {
      purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
      );
    }

    try {
      await inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
    } catch (e) {
      debugPrint("Purchase error: $e");
    }
  }
}
