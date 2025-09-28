import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getsayor/data/services/topup_service.dart';
import 'package:getsayor/presentation/pages/top_up/components/pendingTransaction.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:getsayor/presentation/pages/init_screen.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:getsayor/presentation/pages/top_up/components/success_page.dart';
import 'package:intl/intl.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

class TransactionStatusPage extends StatefulWidget {
  final ProductDetails product;
  final int points;
  final String invoiceNumber;

  const TransactionStatusPage({
    super.key,
    required this.product,
    required this.points,
    required this.invoiceNumber,
  });

  @override
  State<TransactionStatusPage> createState() => _TransactionStatusPageState();
}

class _TransactionStatusPageState extends State<TransactionStatusPage>
    with TickerProviderStateMixin {
  PurchaseStatus _purchaseStatus = PurchaseStatus.pending;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  String? _purchaseId;
  bool _isProcessing = false;
  bool _backendSuccess = false;
  String? _errorMessage;
  PurchaseDetails? _purchaseDetails;
  Timer? _timeoutTimer;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _startPurchase();
    _monitorPurchase();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _subscription?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startTimeoutTimer() {
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!_backendSuccess && _purchaseStatus == PurchaseStatus.pending) {
        setState(() {
          _errorMessage = "Transaksi timeout. Silakan coba lagi";
          _purchaseStatus = PurchaseStatus.error;
        });
        _autoClosePage();
      }
    });
  }

  void _autoClosePage() {
    Timer(const Duration(seconds: 5), () {
      if (mounted && !_backendSuccess) {
        Navigator.pop(context);
      }
    });
  }

  void _startPurchase() async {
    try {
      late PurchaseParam purchaseParam;
      if (Platform.isAndroid) {
        purchaseParam = GooglePlayPurchaseParam(
          productDetails: widget.product,
          applicationUserName: null,
        );
      } else {
        purchaseParam = PurchaseParam(
          productDetails: widget.product,
          applicationUserName: null,
        );
      }

      final bool paymentInitiated = await InAppPurchase.instance.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );

      if (!paymentInitiated) {
        setState(() {
          _purchaseStatus = PurchaseStatus.error;
          _errorMessage = "Gagal memulai pembayaran";
        });
        _autoClosePage();
      }
    } catch (e) {
      setState(() {
        _purchaseStatus = PurchaseStatus.error;
        _errorMessage = "Error: $e";
      });
      _autoClosePage();
    }
  }

  void _monitorPurchase() {
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      (purchases) {
        _handlePurchaseUpdate(purchases);
      },
      onError: (error) {
        setState(() {
          _purchaseStatus = PurchaseStatus.error;
          _errorMessage = error.toString();
        });
        _autoClosePage();
      },
    );
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID == widget.product.id) {
        setState(() {
          _purchaseStatus = purchase.status;
          _purchaseDetails = purchase;
        });

        if (purchase.status == PurchaseStatus.canceled) {
          _errorMessage = "Pembelian dibatalkan";
          _autoClosePage();
        } else if (purchase.status == PurchaseStatus.error) {
          _errorMessage = purchase.error?.message ?? "Unknown error";
          _autoClosePage();
        } else if (purchase.status == PurchaseStatus.purchased) {
          _purchaseId = purchase.purchaseID;
          _processPurchase();
        }

        if (purchase.status != PurchaseStatus.pending) {
          _subscription?.cancel();
          _timeoutTimer?.cancel();
        }
        break;
      }
    }
  }

  Future<void> _processPurchase() async {
    if (_isProcessing || _backendSuccess) return;
    setState(() => _isProcessing = true);

    try {
      // Validasi purchaseID
      if (_purchaseId == null || _purchaseId!.isEmpty) {
        throw Exception("Invalid purchase ID");
      }

      // Simpan transaksi ke pending storage terlebih dahulu
      await PendingTransactionStorage.addPendingTransaction(
        PendingTransaction(
          purchaseId: _purchaseId!,
          points: widget.points,
          price: widget.product.price,
          date: DateTime.now(),
          invoiceNumber: widget.invoiceNumber,
        ),
      );

      // Dapatkan token dan userId
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = prefs.getString('userId') ?? '';

      if (token.isEmpty || userId.isEmpty) {
        throw Exception("User not authenticated");
      }

      // Kirim data ke backend
      await _sendTopUpToBackend(
        token: token,
        userId: userId,
        purchaseId: _purchaseId!,
      );

      // Hapus dari pending dan tandai sebagai selesai
      await PendingTransactionStorage.removePendingTransaction(_purchaseId!);
      await _saveCompletedPurchaseId(_purchaseId!);

      // Selesaikan pembelian
      if (_purchaseDetails != null) {
        await InAppPurchase.instance.completePurchase(_purchaseDetails!);
      }

      setState(() => _backendSuccess = true);
    } catch (e) {
      // Jangan hapus dari pending storage jika gagal
      setState(() {
        _errorMessage = "Gagal mengirim data. Akan dicoba ulang nanti";
      });

      // Tetap tampilkan UI sukses pembelian
      if (_purchaseStatus == PurchaseStatus.purchased) {
        setState(() => _backendSuccess = true);
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _sendTopUpToBackend({
    required String token,
    required String userId,
    required String purchaseId,
  }) async {
    try {
      final priceValue = _parsePrice(widget.product.price);

      // Konversi userId ke integer
      final int userIdInt = int.tryParse(userId) ?? 0;
      if (userIdInt <= 0) {
        throw Exception("Invalid user ID format");
      }

      await TopUpPoinService().postTopUpData(
        token,
        userIdInt,
        widget.points,
        priceValue,
        DateTime.now(),
        "In-App Purchase",
        purchaseId,
        widget.invoiceNumber,
      );
    } catch (e) {
      rethrow;
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

  Future<void> _saveCompletedPurchaseId(String purchaseId) async {
    final prefs = await SharedPreferences.getInstance();
    final completedIds = prefs.getStringList('completed_purchase_ids') ?? [];
    if (!completedIds.contains(purchaseId)) {
      completedIds.add(purchaseId);
      await prefs.setStringList('completed_purchase_ids', completedIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_purchaseStatus == PurchaseStatus.purchased && _backendSuccess) {
      return SuccessPage(
        points: widget.points,
        price: widget.product.price,
        date: DateTime.now(),
        invoiceNumber: widget.invoiceNumber,
        onComplete: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const InitScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      );
    }

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeController,
        child: Column(
          children: [
            // Header section based on status
            _buildHeader(),

            // White content section
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    Color primaryColor;
    Color secondaryColor;
    IconData iconData;
    String titleText;
    String subtitleText;

    switch (_purchaseStatus) {
      case PurchaseStatus.pending:
        primaryColor = const Color(0xFF2F80ED);
        secondaryColor = const Color(0xFF00ACC1);
        iconData = Icons.access_time;
        titleText = "Menunggu Konfirmasi";
        subtitleText = "Silakan selesaikan pembayaran di Google Play";
        break;
      case PurchaseStatus.purchased:
        primaryColor = const Color(0xFF10B981);
        secondaryColor = const Color(0xFF00D4AA);
        iconData = Icons.sync;
        titleText = "Memproses Pembelian";
        subtitleText = "Poin sedang ditambahkan ke akun Anda";
        break;
      case PurchaseStatus.error:
      case PurchaseStatus.canceled:
        primaryColor = const Color(0xFFEF4444);
        secondaryColor = const Color(0xFFDC2626);
        iconData = Icons.error_outline;
        titleText = "Transaksi Gagal";
        subtitleText = _errorMessage ?? "Terjadi kesalahan saat memproses";
        break;
      default:
        primaryColor = const Color(0xFF2F80ED);
        secondaryColor = const Color(0xFF00ACC1);
        iconData = Icons.help_outline;
        titleText = "Status Transaksi";
        subtitleText = "Memproses transaksi Anda";
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor, secondaryColor],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            children: [
              // Status Icon
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _purchaseStatus == PurchaseStatus.pending
                        ? 1.0 + (_pulseController.value * 0.1)
                        : 1.0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        iconData,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Status Title
              Text(
                titleText,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Price
              Text(
                widget.product.price,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Status message card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: _buildStatusIcon(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          final fullname = userProvider.fullname ?? 'User';
                          final firstName = fullname.split(' ').first;
                          return Text(
                            _getStatusMessage(firstName),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (_purchaseStatus) {
      case PurchaseStatus.pending:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case PurchaseStatus.purchased:
        return const Icon(
          Icons.hourglass_bottom,
          color: Colors.white,
          size: 20,
        );
      case PurchaseStatus.error:
      case PurchaseStatus.canceled:
        return const Icon(
          Icons.warning,
          color: Colors.white,
          size: 20,
        );
      default:
        return const Icon(
          Icons.help_outline,
          color: Colors.white,
          size: 20,
        );
    }
  }

  String _getStatusMessage(String firstName) {
    switch (_purchaseStatus) {
      case PurchaseStatus.pending:
        return 'Hi, $firstName, mohon tunggu konfirmasi pembayaran';
      case PurchaseStatus.purchased:
        return 'Hi, $firstName, poin sedang diproses untuk Anda';
      case PurchaseStatus.error:
      case PurchaseStatus.canceled:
        return 'Hi, $firstName, terjadi masalah dengan transaksi';
      default:
        return 'Hi, $firstName, memproses transaksi Anda';
    }
  }

  Widget _buildContent() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning card (only show for pending and processing)
              if (_purchaseStatus == PurchaseStatus.pending ||
                  (_purchaseStatus == PurchaseStatus.purchased &&
                      !_backendSuccess))
                _buildWarningCard(),

              const SizedBox(height: 20),

              // Detail Transaksi Header
              const Text(
                "Detail Transaksi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),

              const SizedBox(height: 20),

              // Transaction Details
              _buildDetailItem("ID Pemesanan", widget.invoiceNumber),
              _buildDetailItem("Poin", "${widget.points}"),
              _buildDetailItem("Harga", widget.product.price),
              _buildDetailItem("Metode Pembayaran", "In App Purchase"),
              _buildDetailItem("Status", _getStatusText()),

              const SizedBox(height: 32),

              // Payment Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Pembayaran",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      widget.product.price,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Button (only show for error status)
              if (_purchaseStatus == PurchaseStatus.error ||
                  _purchaseStatus == PurchaseStatus.canceled)
                _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFBBF24),
          width: 1,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF59E0B),
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Jangan meninggalkan halaman ini sampai transaksi selesai",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    bool isPoin = label == "Poin";
    bool isStatus = label == "Status";

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          if (isPoin)
            Row(
              children: [
                Image.asset("assets/images/poin.png", width: 16, height: 16),
                const SizedBox(width: 4),
                Text(
                  "${widget.points}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isStatus ? _getStatusColor() : const Color(0xFF1A1A1A),
              ),
            ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (_purchaseStatus) {
      case PurchaseStatus.pending:
        return "Menunggu Pembayaran";
      case PurchaseStatus.purchased:
        return _isProcessing ? "Memproses" : "Berhasil";
      case PurchaseStatus.error:
        return "Gagal";
      case PurchaseStatus.canceled:
        return "Dibatalkan";
      default:
        return "Tidak Diketahui";
    }
  }

  Color _getStatusColor() {
    switch (_purchaseStatus) {
      case PurchaseStatus.pending:
        return const Color(0xFF2F80ED);
      case PurchaseStatus.purchased:
        return const Color(0xFF10B981);
      case PurchaseStatus.error:
      case PurchaseStatus.canceled:
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F80ED),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Kembali",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
