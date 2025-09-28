import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getsayor/data/model/poin_model.dart';
import 'package:getsayor/data/services/topup_service.dart';
import 'package:getsayor/data/services/poin_service.dart';
import 'package:getsayor/presentation/pages/loading_page.dart';
import 'package:getsayor/presentation/pages/top_up/components/Transaction_status_page.dart';
import 'package:getsayor/presentation/pages/top_up/components/pendingTransaction.dart';
import 'package:intl/intl.dart';
import 'package:onepref/onepref.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");
final formattedDate = DateFormat("dd MMMM yyyy - HH:mm", "id_ID");

class BuyPoints extends StatefulWidget {
  const BuyPoints({super.key});
  static String routeName = "/buypoints";

  @override
  State<BuyPoints> createState() => _BuyPointsState();
}

class _BuyPointsState extends State<BuyPoints> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
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
  Timer? _retryTimer;
  Map<String, bool> _buttonLoadingStates = {};

  final Map<String, Completer<void>> _activePurchases = {};
  final Set<String> _processingPurchaseIds = {};

  @override
  void initState() {
    super.initState();
    _initConnectivityListener();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadUserData();
      await _loadCompletedPurchaseIds();
      await _loadReward();
      await _loadPoins();
      _retryPendingTransactions();
    });

    StreamSubscription<List<PurchaseDetails>>? purchaseSubscription;
    purchaseSubscription = iApEngine.inAppPurchase.purchaseStream.listen(
      _handlePurchases,
      onDone: () => purchaseSubscription?.cancel(),
      onError: (error) => debugPrint("Purchase stream error: $error"),
    );

    _startRetryTimer();
  }

  // Tambahkan listener konektivitas
  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        _retryPendingTransactions();
      }
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    OnePref.setString('token', prefs.getString('token') ?? '');
    OnePref.setString('userId', prefs.getString('userId') ?? '');
  }

  Future<void> refreshToken() async {
    try {
      debugPrint("Refreshing token...");
      final prefs = await SharedPreferences.getInstance();
      final newToken =
          "refreshed_token_${DateTime.now().millisecondsSinceEpoch}";
      await prefs.setString('token', newToken);
      OnePref.setString('token', newToken);
      debugPrint("Token refreshed successfully");
    } catch (e) {
      debugPrint("Token refresh failed: $e");
      throw TopUpException('Gagal memperbarui sesi. Silakan login ulang',
          retryable: false);
    }
  }

  void _startRetryTimer() {
    _retryTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (_isPurchaseHandlerLocked) return;
      await _retryPendingTransactions();
    });
  }

  Future<void> _loadCompletedPurchaseIds() async {
    final prefs = await SharedPreferences.getInstance();
    final completedIds = prefs.getStringList('completed_purchase_ids') ?? [];
    _completedBackendPurchaseIds.addAll(completedIds);
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    if (_isPurchaseHandlerLocked) return;
    _isPurchaseHandlerLocked = true;

    try {
      for (final purchase in purchases) {
        final purchaseId = purchase.purchaseID ?? '';
        if (purchaseId.isEmpty ||
            _completedPurchases.contains(purchaseId) ||
            _completedBackendPurchaseIds.contains(purchaseId) ||
            _activePurchases.containsKey(purchaseId)) {
          await _completePurchase(purchase);
          continue;
        }

        final completer = Completer<void>();
        _activePurchases[purchaseId] = completer;

        try {
          await _processPurchase(purchase);
          completer.complete();
        } catch (e) {
          completer.completeError(e);
        } finally {
          _activePurchases.remove(purchaseId);
        }
      }
    } finally {
      _isPurchaseHandlerLocked = false;
    }
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
        _errorMessage = null;
      });

      debugPrint("Fetching poins from API...");
      final poins = await PoinService().fetchPoin(context);

      debugPrint("Received ${poins.length} poin items");
      for (int i = 0; i < poins.length; i++) {
        final poin = poins[i];
        debugPrint("Item $i: "
            "ID: ${poin.id}, "
            "Poin: ${poin.poin}, "
            "ProductID: ${poin.productId}, "
            "PromoProductID: ${poin.promoProductId ?? 'null'}, ");
      }

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
    debugPrint("Fetching IAP products...");
    if (poinList.isEmpty) return;

    final productIds = poinList
        .map((poin) => [poin.productId, poin.promoProductId])
        .expand((id) => id)
        .where((id) => id != null && id.isNotEmpty)
        .whereType<String>()
        .toList();

    debugPrint("Product IDs to query: $productIds");

    if (await iApEngine.getIsAvailable()) {
      try {
        final response = await iApEngine.queryProducts(productIds);
        debugPrint("Found ${response.productDetails.length} products");
        debugPrint(
            "Not found IDs: ${response.notFoundIDs}"); // Log IDs yang tidak ditemukan

        if (mounted) {
          setState(() => _products = response.productDetails);
        }
      } catch (e) {
        debugPrint("Error fetching products: $e");
        setState(() => _errorMessage = 'Failed to load products');
      }
    } else {
      debugPrint("IAP not available");
      setState(() => _errorMessage = 'In-app purchases unavailable');
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
    final purchaseId = purchase.purchaseID ?? '';
    if (purchaseId.isEmpty) {
      await _completePurchase(purchase);
      return;
    }

    final poin = poinList.firstWhere(
      (p) =>
          p.productId == purchase.productID ||
          (p.promoProductId != null && p.promoProductId == purchase.productID),
      orElse: () => Poin(id: 0, poin: 0, productId: ""),
    );

    if (poin.poin <= 0) {
      await _completePurchase(purchase);
      return;
    }

    final invoiceNumber = "INV-${DateTime.now().millisecondsSinceEpoch}";

    await PendingTransactionStorage.addPendingTransaction(
      PendingTransaction(
        purchaseId: purchaseId,
        points: poin.poin,
        price: _getProduct(purchase.productID)?.price ?? "",
        date: DateTime.now(),
        invoiceNumber: invoiceNumber,
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getString('userId') ?? '';

      if (token.isEmpty || userId.isEmpty) {
        throw TopUpException('User not authenticated', retryable: false);
      }

      // Gunakan lock processing
      if (_processingPurchaseIds.contains(purchaseId)) return;
      _processingPurchaseIds.add(purchaseId);

      await _sendTopUpToBackend(
        token: token,
        userId: userId,
        points: poin.poin,
        price: _getProduct(purchase.productID)?.price ?? "",
        purchaseId: purchaseId,
        invoiceNumber: invoiceNumber,
        isBackground: true,
      );

      await PendingTransactionStorage.removePendingTransaction(purchaseId);
      await _saveCompletedPurchaseId(purchaseId);

      final newReward = reward + poin.poin;
      OnePref.setInt("points", newReward);
      if (mounted) setState(() => reward = newReward);

      // PERBAIKAN: Untuk Android, coba konsumsi pembelian
      if (Platform.isAndroid) {
        try {
          final androidAddition = iApEngine.inAppPurchase
              .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
          await androidAddition.consumePurchase(purchase);
          debugPrint("Produk dikonsumsi: ${purchase.productID}");
        } catch (e) {
          debugPrint("Gagal mengonsumsi produk: $e");
          await _savePendingConsumption(purchaseId);
        }
      }
    } catch (e) {
      debugPrint("Background top-up submission failed: $e");
    } finally {
      _processingPurchaseIds.remove(purchaseId);
      await _completePurchase(purchase);
    }
  }

  Future<void> _completePurchase(PurchaseDetails purchase) async {
    try {
      await iApEngine.inAppPurchase.completePurchase(purchase);
    } catch (e) {
      debugPrint("Error completing purchase: $e");
    }
  }

  Future<void> _savePendingConsumption(String purchaseId) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList('pending_consumptions') ?? [];
    if (!pending.contains(purchaseId)) {
      pending.add(purchaseId);
      await prefs.setStringList('pending_consumptions', pending);
    }
  }

  Future<void> _retryPendingTransactions() async {
    debugPrint("Retrying pending transactions...");
    final token = OnePref.getString('token') ?? '';
    final userId = OnePref.getString('userId') ?? '';

    if (token.isEmpty || userId.isEmpty) {
      debugPrint("Skipping retry: User not authenticated");
      return;
    }

    final pendingTransactions =
        await PendingTransactionStorage.getPendingTransactions();
    debugPrint("Found ${pendingTransactions.length} pending transactions");

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

        // Jika sukses, hapus dari pending dan update poin
        await PendingTransactionStorage.removePendingTransaction(
            transaction.purchaseId);
        await _saveCompletedPurchaseId(transaction.purchaseId);

        final newReward = reward + transaction.points;
        OnePref.setInt("points", newReward);
        if (mounted) {
          setState(() => reward = newReward);
        }
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
    bool isBackground = false,
  }) async {
    try {
      // PERBAIKAN: Validasi duplikasi sebelum kirim
      if (_processingPurchaseIds.contains(purchaseId)) {
        debugPrint("Purchase $purchaseId already being processed");
        return;
      }
      _processingPurchaseIds.add(purchaseId);

      final priceValue = _parsePrice(price);
      final userIdInt = int.tryParse(userId) ?? 0;

      if (userIdInt <= 0) throw Exception("Invalid user ID");

      await TopUpPoinService().postTopUpData(
        token,
        userIdInt,
        points,
        priceValue,
        DateTime.now(),
        "In-App Purchase",
        purchaseId,
        invoiceNumber,
      );

      debugPrint("Top-up backend success!");
      if (!isBackground) {
        Fluttertoast.showToast(
          msg: 'Top Up Berhasil!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } on DioException catch (e) {
      // PERBAIKAN: Handle error 409 khusus
      if (e.response?.statusCode == 409) {
        debugPrint("Purchase $purchaseId already processed");
        await PendingTransactionStorage.removePendingTransaction(purchaseId);
        await _saveCompletedPurchaseId(purchaseId);
        return;
      }
      rethrow;
    } finally {
      _processingPurchaseIds.remove(purchaseId);
    }
  }

  Future<void> _saveCompletedPurchaseId(String purchaseId) async {
    final prefs = await SharedPreferences.getInstance();
    final completedIds = prefs.getStringList('completed_purchase_ids') ?? [];
    if (!completedIds.contains(purchaseId)) {
      completedIds.add(purchaseId);
      await prefs.setStringList('completed_purchase_ids', completedIds);
      _completedBackendPurchaseIds.add(purchaseId);
    }
  }

  int _parsePrice(String priceStr) {
    try {
      priceStr = priceStr.replaceAll(RegExp(r'[^0-9.,]'), '');

      if (priceStr.contains(',') && priceStr.contains('.')) {
        final lastComma = priceStr.lastIndexOf(',');
        final lastDot = priceStr.lastIndexOf('.');
        if (lastComma > lastDot) {
          priceStr = priceStr.replaceAll('.', '').replaceAll(',', '.');
        } else {
          priceStr = priceStr.replaceAll(',', '');
        }
      } else if (priceStr.contains(',')) {
        priceStr = priceStr.replaceAll(',', '.');
      }

      final value = double.tryParse(priceStr) ?? 0;
      return (value * 100).toInt();
    } catch (e) {
      return 0;
    }
  }

  Future<void> _initiatePurchase(ProductDetails product, int points,
      String productId, BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F80ED).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Color(0xFF2F80ED),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    "Konfirmasi Pembelian",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Content
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Poin:",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              "${numberFormat.format(points)} poin",
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Harga:",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              product.price,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2F80ED),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F80ED),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Lanjutkan",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;

    if (!confirmed) {
      setState(() => _buttonLoadingStates[productId] = false);
      return;
    }

    // Generate invoice number
    final invoiceNumber =
        "INV-${DateFormat('yyyyMMdd').format(DateTime.now())}-"
        "${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

    // Navigate to transaction page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionStatusPage(
          product: product,
          points: points,
          invoiceNumber: invoiceNumber,
        ),
      ),
    ).then((_) {
      setState(() => _buttonLoadingStates[productId] = false);
    });
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
    return Stack(
      children: [
        Scaffold(
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
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Color(0xFF1F2131)),
                onPressed: _showTopUpInfo,
              ),
            ],
          ),
          resizeToAvoidBottomInset: false,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
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
                      final productId = displayProduct?.id ?? '';

                      bool isConsistent = displayProduct != null &&
                          _isDescriptionMatchesPoin(
                              displayProduct.description, poin.poin);

                      final isLoadingButton =
                          _buttonLoadingStates[productId] ?? false;

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
                                      child: Image.asset(
                                          'assets/images/poin.png',
                                          width: 42),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            decoration:
                                                TextDecoration.lineThrough,
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
                                onTap: displayProduct != null &&
                                        !isLoading &&
                                        !isLoadingButton
                                    ? () {
                                        setState(() =>
                                            _buttonLoadingStates[productId] =
                                                true);
                                        _initiatePurchase(displayProduct,
                                            poin.poin, productId, context);
                                      }
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLoadingButton
                                        ? Colors.grey
                                        : const Color(0xFF2F80ED),
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
            ],
          ),
        ),

        // Loading overlay yang menutupi seluruh layar
        if (isLoading)
          AnimatedOpacity(
            opacity: isLoading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: const LoadingPage(),
          ),
      ],
    );
  }
}

class IApEngine {
  final InAppPurchase inAppPurchase = InAppPurchase.instance;

  Future<bool> getIsAvailable() async => await inAppPurchase.isAvailable();

  Future<ProductDetailsResponse> queryProducts(List<String> productIds) async {
    return await inAppPurchase.queryProductDetails(productIds.toSet());
  }

  // Fungsi untuk mendapatkan pembelian sebelumnya
  Future<List<PurchaseDetails>> getPurchases() async {
    if (Platform.isAndroid) {
      final InAppPurchaseAndroidPlatformAddition androidAddition = inAppPurchase
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final response = await androidAddition.queryPastPurchases();
      return response.pastPurchases;
    }
    return [];
  }

  Future<void> handlePurchase({
    required ProductDetails productDetails,
    required int pointAmount,
  }) async {
    try {
      // Generate invoice number immediately
      final invoiceNumber =
          "INV-${DateFormat('yyyyMMdd').format(DateTime.now())}-"
          "${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

      // Save transaction to SharedPreferences BEFORE starting payment
      await PendingTransactionStorage.addPendingTransaction(
        PendingTransaction(
          purchaseId: "", // Will be updated later
          points: pointAmount,
          price: productDetails.price,
          date: DateTime.now(),
          invoiceNumber: invoiceNumber,
        ),
      );

      // Proceed with payment
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

      final bool paymentInitiated = await inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );

      if (!paymentInitiated) {
        await PendingTransactionStorage.removePendingTransaction("");
      }
    } catch (e) {
      debugPrint("Purchase error: $e");
      await PendingTransactionStorage.removePendingTransaction("");
      rethrow;
    }
  }
}
