import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/init_screen.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

class OrderConfirmationCartPage extends StatefulWidget {
  final List<String> namaProduk;
  final List<int> jumlah;
  final List<int> berat;
  final List<String> hargaProduk;
  final List<String> satuan;
  final String ongkir;
  final String totalHarga;
  final String totalBayar;
  final String invoiceNumber;
  final String orderDate;

  const OrderConfirmationCartPage({
    required this.namaProduk,
    required this.jumlah,
    required this.berat,
    required this.hargaProduk,
    required this.satuan,
    required this.ongkir,
    required this.totalHarga,
    required this.totalBayar,
    required this.invoiceNumber,
    required this.orderDate,
    super.key,
  });

  @override
  State<OrderConfirmationCartPage> createState() =>
      _OrderConfirmationCartPageState();
}

class _OrderConfirmationCartPageState extends State<OrderConfirmationCartPage>
    with TickerProviderStateMixin {
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

  bool isRupiahFormat(String text) {
    return text.contains('Rp');
  }

  int getTotalWeight() {
    int totalWeight = 0;
    for (int i = 0; i < widget.berat.length; i++) {
      totalWeight += widget.berat[i];
    }
    return totalWeight;
  }

  String getFirstUnit() {
    return widget.satuan.isNotEmpty ? widget.satuan[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDateFormatInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF589400),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    final formattedDate = _formatOrderDate(widget.orderDate);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Column(
                children: [
                  // Green Header Section
                  _buildGreenHeader(),

                  // White Content Section
                  _buildWhiteContent(formattedDate),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreenHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF589400),
            Color(0xFF74B11A),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: Column(
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF589400),
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // Success Text
              const Text(
                "Order Successfully!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Total Amount
              Text(
                widget.totalBayar,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 24),

              // Notification Card
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
                      decoration: const BoxDecoration(
                        color: Color(0xFF74B11A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Pengantaran produk dimulai setiap hari pukul 05.00 pagi untuk memastikan pesanan tiba cepat dan tepat waktu.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildWhiteContent(String formattedDate) {
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
        child: Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Detail Order Header
                  const Text(
                    "Detail Pesanan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Order Details
                  _buildDetailItem("No Invoice", widget.invoiceNumber),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      final fullname = userProvider.fullname ?? 'User';
                      return _buildDetailItem("Nama", fullname);
                    },
                  ),
                  _buildDetailItem("Tanggal", formattedDate),
                  _buildDetailItem(
                      "Total Produk", "${widget.namaProduk.length} Items"),
                  // _buildDetailItem(
                  //     "Total Berat", "${getTotalWeight()} ${getFirstUnit()}"),

                  const SizedBox(height: 24),

                  // Products List
                  const Text(
                    "Daftar Produk",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Product Items
                  ...widget.namaProduk.asMap().entries.map((entry) {
                    int index = entry.key;
                    String productName = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE9ECEF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Product Details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Jumlah: x${widget.jumlah[index]}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                "Berat: ${widget.berat[index]} ${widget.satuan[index]}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Product Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Harga:",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              isRupiahFormat(widget.hargaProduk[index])
                                  ? Text(
                                      widget.hargaProduk[index],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF589400),
                                        fontFamily: 'Poppins',
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/poin.png',
                                          width: 14,
                                          height: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          numberFormat.format(int.parse(
                                              widget.hargaProduk[index])),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF589400),
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 24),

                  // Payment Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Column(
                      children: [
                        // Total Harga Produk
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Harga Produk",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF666666),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            isRupiahFormat(widget.totalHarga)
                                ? Text(
                                    widget.totalHarga,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                      fontFamily: 'Poppins',
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/poin.png',
                                        width: 16,
                                        height: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        numberFormat.format(
                                            int.parse(widget.totalHarga)),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A1A1A),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Ongkos Kirim
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Ongkos Kirim",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF666666),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            isRupiahFormat(widget.ongkir)
                                ? Text(
                                    widget.ongkir,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                      fontFamily: 'Poppins',
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/poin.png',
                                        width: 16,
                                        height: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        numberFormat
                                            .format(int.parse(widget.ongkir)),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A1A1A),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFE9ECEF)),
                        const SizedBox(height: 12),

                        // Total Pembayaran
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Pembayaran",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF589400),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            isRupiahFormat(widget.totalBayar)
                                ? Text(
                                    widget.totalBayar,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF589400),
                                      fontFamily: 'Poppins',
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/poin.png',
                                        width: 18,
                                        height: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        numberFormat.format(
                                            int.parse(widget.totalBayar)),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF589400),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Fixed bottom button
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
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
                    backgroundColor: const Color(0xFF589400),
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
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatOrderDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('d MMMM yyyy - HH:mm', 'id_ID').format(date);
    } catch (e) {
      return "Invalid date";
    }
  }
}
