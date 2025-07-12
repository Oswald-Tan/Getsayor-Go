import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getsayor/presentation/pages/init_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

class SuccessPage extends StatefulWidget {
  final int points;
  final String price;
  final String? originalPrice;
  final DateTime date;
  final String invoiceNumber;

  const SuccessPage({
    super.key,
    required this.points,
    required this.price,
    this.originalPrice,
    required this.date,
    required this.invoiceNumber,
  });

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage>
    with TickerProviderStateMixin {
  String formattedDate = "";
  String invoiceNumber = "";
  bool _isDateFormatInitialized = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _initializeDateFormat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeDateFormat() async {
    await initializeDateFormatting('id_ID', null);
    setState(() {
      _isDateFormatInitialized = true;
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDateFormatInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF74B11A)),
          ),
        ),
      );
    }

    final formattedDate =
        DateFormat("dd MMM yyyy • HH:mm", "id_ID").format(widget.date);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Column(
                  children: [
                    // Success Header
                    _buildSuccessHeader(),

                    // Main Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Transaction Details
                            _buildDetailsCard(formattedDate),
                            const SizedBox(height: 24),
                            // Transaction Summary Card
                            _buildTransactionCard(),

                            const SizedBox(height: 32),

                            // Info Note
                            _buildInfoNote(),
                          ],
                        ),
                      ),
                    ),

                    // Action Button
                    _buildActionButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/success.svg',
            width: 140,
            height: 140,
          ),
          const SizedBox(height: 24),
          const Text(
            "Pembayaran Berhasil",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Transaksi Anda telah berhasil diproses",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Points Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF74B11A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: Color(0xFF74B11A),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    const Text(
                      "Poin Berhasil Dibeli",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${numberFormat.format(widget.points)} Poin",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF74B11A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Payment Summary
          _buildPaymentSummary(),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ringkasan Pembayaran",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.originalPrice != null) ...[
          _buildPaymentRow("Harga Asli", widget.originalPrice!,
              isStriked: true),
          const SizedBox(height: 8),
          _buildPaymentRow("Diskon", "-${_calculateDiscount()}",
              isDiscount: true),
          const SizedBox(height: 8),
          const Divider(height: 24),
        ],
        _buildPaymentRow("Total Dibayar", widget.price, isTotal: true),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value,
      {bool isStriked = false, bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? const Color(0xFF1A1A1A) : const Color(0xFF666666),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal
                ? const Color(0xFF74B11A)
                : isDiscount
                    ? const Color(0xFFE53E3E)
                    : const Color(0xFF1A1A1A),
            decoration: isStriked ? TextDecoration.lineThrough : null,
            decorationColor: const Color(0xFFE53E3E),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(String formattedDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detail Transaksi",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow("Invoice", widget.invoiceNumber),
          const SizedBox(height: 12),
          _buildDetailRow("Tanggal", formattedDate),
          const SizedBox(height: 12),
          _buildDetailRow("Status", "Berhasil", isStatus: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        isStatus
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF74B11A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF74B11A),
                  ),
                ),
              )
            : Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
      ],
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF74B11A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF74B11A).withOpacity(0.2),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF74B11A),
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Poin akan otomatis masuk ke akun Anda dalam 1-2 menit",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF74B11A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
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
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF74B11A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            "Kembali ke Beranda",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String _calculateDiscount() {
    if (widget.originalPrice == null) return "Rp 0";

    try {
      int parsePrice(String priceStr) {
        final cleaned = priceStr
            .replaceAll('Rp', '')
            .replaceAll('.', '')
            .replaceAll(',', '')
            .trim();
        return int.tryParse(cleaned) ?? 0;
      }

      final originalPrice = parsePrice(widget.originalPrice!);
      final currentPrice = parsePrice(widget.price);
      final discount = originalPrice - currentPrice;

      final currencyFormat = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

      return currencyFormat.format(discount);
    } catch (e) {
      return "Rp 0";
    }
  }
}
