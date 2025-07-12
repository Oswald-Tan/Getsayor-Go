import 'package:flutter/material.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/data/model/pesanan_model.dart';
import 'package:getsayor/data/services/pesanan_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:getsayor/cache_manager/cache_manager.dart';
import 'package:getsayor/presentation/pages/produk/components/order_detail.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

String formatTanggal(String isoDate) {
  DateTime dateTime = DateTime.parse(isoDate).toLocal();
  return DateFormat('dd MMM yyyy').format(dateTime);
}

final currencyFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

String formatRupiah(int value) {
  return currencyFormat.format(value).replaceAll('Rp', 'Rp. ');
}

class OrderPage extends StatefulWidget {
  final int userId;
  static const routeName = '/order-page';

  const OrderPage({super.key, required this.userId});

  @override
  OrderPageState createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> {
  final PesananService _pesananService = PesananService();
  late Future<List<PesananModel>> _pesananFuture;
  String _selectedFilter = 'In Progress'; // Default filter
  String _selectedTimeFilter = 'today'; // all, today, week, month, year, custom
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFiltering = false;

  static const Map<String, String> statusMap = {
    'pending': 'Menunggu',
    'confirmed': 'Dikonfirmasi',
    'processed': 'Diproses',
    'out-for-delivery': 'Dalam Pengiriman',
    'delivered': 'Terkirim',
    'cancelled': 'Dibatalkan',
  };

  static const Map<String, String> paymentStatusMap = {
    'unpaid': 'Belum Dibayar',
    'paid': 'Dibayar',
  };

  final List<Map<String, dynamic>> filters = [
    // {
    //   'key': 'All',
    //   'displayName': 'Semua',
    //   'iconAsset': 'assets/icons/all.png',
    //   'color': Colors.lightBlueAccent,
    // },
    {
      'key': 'In Progress',
      'displayName': 'Di Proses',
      'iconAsset': 'assets/icons/in_progress.png',
      'color': Colors.orange,
    },
    {
      'key': 'Delivered',
      'displayName': 'Terkirim',
      'iconAsset': 'assets/icons/delivered.png',
      'color': Colors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _pesananFuture = _pesananService.getPesananByUser(context, widget.userId);
    });
  }

  void _fetchData() {
    _pesananFuture = _pesananService.getPesananByUser(context, widget.userId);
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _applyTimeFilter(String filter) {
    setState(() {
      _selectedTimeFilter = filter;
      _isFiltering = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isFiltering = false;
        });
      }
    });
  }

  void _handleCustomDateSelected(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _selectedTimeFilter = 'custom';
      _isFiltering = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isFiltering = false;
        });
      }
    });
  }

  List<PesananModel> _filterByTime(List<PesananModel> pesananList) {
    // if (_selectedTimeFilter == 'all') {
    //   return pesananList;
    // }

    final now = DateTime.now();

    switch (_selectedTimeFilter) {
      case 'today':
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = todayStart.add(const Duration(days: 1));
        return pesananList.where((pesanan) {
          final orderDate = DateTime.parse(pesanan.createdAt).toLocal();
          return orderDate.isAfter(todayStart) && orderDate.isBefore(todayEnd);
        }).toList();

      case 'week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return pesananList.where((pesanan) {
          final orderDate = DateTime.parse(pesanan.createdAt).toLocal();
          return orderDate.isAfter(startOfWeek) &&
              orderDate.isBefore(endOfWeek);
        }).toList();

      case 'month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 1);
        return pesananList.where((pesanan) {
          final orderDate = DateTime.parse(pesanan.createdAt).toLocal();
          return orderDate.isAfter(startOfMonth) &&
              orderDate.isBefore(endOfMonth);
        }).toList();

      case 'year':
        final startOfYear = DateTime(now.year, 1, 1);
        final endOfYear = DateTime(now.year + 1, 1, 1);
        return pesananList.where((pesanan) {
          final orderDate = DateTime.parse(pesanan.createdAt).toLocal();
          return orderDate.isAfter(startOfYear) &&
              orderDate.isBefore(endOfYear);
        }).toList();

      case 'custom':
        if (_startDate == null || _endDate == null) return pesananList;
        final customEnd = _endDate!.add(const Duration(days: 1));
        return pesananList.where((pesanan) {
          final orderDate = DateTime.parse(pesanan.createdAt).toLocal();
          return orderDate.isAfter(_startDate!) &&
              orderDate.isBefore(customEnd);
        }).toList();

      default:
        return pesananList;
    }
  }

  // Widget untuk menampilkan error
  Widget _buildErrorWidget(String errorMessage) {
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
              'Gagal Memuat Pesanan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
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
                onPressed: _refreshData,
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilterButton(String text, String value) {
    final isSelected = _selectedTimeFilter == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _applyTimeFilter(value),
          borderRadius: BorderRadius.circular(24),
          splashColor: const Color(0xFF74B11A).withOpacity(0.1),
          highlightColor: const Color(0xFF74B11A).withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF74B11A) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF74B11A)
                    : const Color(0xFFE8E8E8),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: const Color(0xFF74B11A).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                if (!isSelected)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon indicator for selected state
                if (isSelected) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Text
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF666666),
                    letterSpacing: 0.2,
                  ),
                  child: Text(text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTimeFilterButton(BuildContext context) {
    final isSelected = _selectedTimeFilter == 'custom';
    return GestureDetector(
      onTap: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          initialDateRange: _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF74B11A),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                  background: Colors.white,
                ),
                dialogBackgroundColor: Colors.white,
                scaffoldBackgroundColor: Colors.white,
                cardColor: Colors.white,
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(
                    color: Colors.black,
                  ),
                  bodyMedium:
                      TextStyle(color: Colors.black, fontFamily: "Poppins"),
                  titleLarge:
                      TextStyle(color: Colors.black, fontFamily: "Poppins"),
                  titleMedium:
                      TextStyle(color: Colors.black, fontFamily: "Poppins"),
                  labelLarge:
                      TextStyle(color: Colors.black, fontFamily: "Poppins"),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF74B11A),
                  ),
                ),
                dividerTheme: const DividerThemeData(
                  color: Colors.grey,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          _handleCustomDateSelected(picked.start, picked.end);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF74B11A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF74B11A) : const Color(0xFFE5E5E5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF555555),
            ),
            const SizedBox(width: 4),
            Text(
              'Custom',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: isSelected ? Colors.white : const Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToOrderDetail(PesananModel pesanan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailPage(pesanan: pesanan),
      ),
    );
  }

  void _showStatusInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              // Centered title
              const Center(
                child: Text(
                  'Alur Status Pesanan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildStatusStep(
                icon: Icons.access_time,
                color: Colors.orange,
                title: 'Menunggu',
                description:
                    'Pesanan telah dibuat dan menunggu konfirmasi dari penjual.',
              ),
              _buildStatusStep(
                icon: Icons.check_circle,
                color: const Color(0xFF74B11A),
                title: 'Dikonfirmasi',
                description: 'Pesanan telah dikonfirmasi oleh penjual.',
              ),
              _buildStatusStep(
                icon: Icons.build,
                color: Colors.blue,
                title: 'Diproses',
                description: 'Pesanan sedang diproses oleh penjual.',
              ),
              _buildStatusStep(
                icon: Icons.local_shipping,
                color: Colors.purple,
                title: 'Dalam Pengiriman',
                description:
                    'Pesanan sedang dalam perjalanan menuju alamat Anda.',
              ),
              _buildStatusStep(
                icon: Icons.check,
                color: Colors.teal,
                title: 'Terkirim',
                description: 'Pesanan telah sampai di alamat Anda.',
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Helper widget for status steps
  Widget _buildStatusStep({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Order',
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
            onPressed: _showStatusInfo,
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0XFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF74B11A),
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // Menu Filter Status
            Container(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 10, bottom: 10),
              child: Row(
                children: [
                  // Expanded(
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(right: 4),
                  //     child:
                  //         _buildFilterButton('All', _selectedFilter == 'All'),
                  //   ),
                  // ),
                  Expanded(
                    child: _buildFilterButton(
                        'In Progress', _selectedFilter == 'In Progress'),
                  ),
                  const SizedBox(width: 8), // Spasi antar tombol
                  Expanded(
                    child: _buildFilterButton(
                        'Delivered', _selectedFilter == 'Delivered'),
                  ),
                ],
              ),
            ),

            // Menu Filter Waktu
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // _buildTimeFilterButton('Semua', 'all'),
                    // const SizedBox(width: 8),
                    _buildTimeFilterButton('Hari Ini', 'today'),
                    const SizedBox(width: 8),
                    _buildTimeFilterButton('Minggu Ini', 'week'),
                    const SizedBox(width: 8),
                    _buildTimeFilterButton('Bulan Ini', 'month'),
                    const SizedBox(width: 8),
                    _buildTimeFilterButton('Tahun Ini', 'year'),
                    const SizedBox(width: 8),
                    _buildCustomTimeFilterButton(context),
                  ],
                ),
              ),
            ),

            if (_selectedTimeFilter == 'custom' &&
                _startDate != null &&
                _endDate != null)
              Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 0, bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Rentang: ${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF555555),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),

            // List Pesanan
            Expanded(
              child: FutureBuilder<List<PesananModel>>(
                future: _pesananFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      _isFiltering) {
                    return _buildShimmerLoader();
                  } else if (snapshot.hasError) {
                    String errorMessage =
                        'Terjadi kesalahan saat memuat pesanan';
                    if (snapshot.error.toString().contains('Timeout')) {
                      errorMessage =
                          'Koneksi timeout. Pastikan koneksi internet Anda stabil dan coba lagi.';
                    } else if (snapshot.error.toString().contains('network')) {
                      errorMessage =
                          'Tidak ada koneksi internet. Periksa jaringan Anda.';
                    }

                    return _buildErrorWidget(errorMessage);
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/nodata.png',
                            width: 170,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada pesanan',
                            style: TextStyle(
                                fontFamily: 'Poppins', color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter pesanan berdasarkan status
                  List<PesananModel> filteredPesanan = snapshot.data!;

                  filteredPesanan = filteredPesanan.where((pesanan) {
                    // if (_selectedFilter == 'All') return true;
                    if (_selectedFilter == 'In Progress') {
                      return [
                        'pending',
                        'confirmed',
                        'processed',
                        'out-for-delivery'
                      ].contains(pesanan.status);
                    }
                    if (_selectedFilter == 'Delivered') {
                      return pesanan.status == 'delivered';
                    }
                    return false;
                  }).toList();

                  // Filter berdasarkan waktu
                  filteredPesanan = _filterByTime(filteredPesanan);

                  // Tambahkan pengecekan filtered list kosong
                  if (filteredPesanan.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/nodata.png',
                            width: 170,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 'Delivered'
                                ? 'Belum ada pesanan terkirim'
                                : 'Belum ada pesanan',
                            style: const TextStyle(
                                fontFamily: 'Poppins', color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    itemCount: filteredPesanan.length,
                    itemBuilder: (context, index) {
                      final pesanan = filteredPesanan[index];
                      final isLastItem = index ==
                          filteredPesanan.length -
                              1; // Cek apakah item terakhir
                      return _buildPesananItem(pesanan, isLastItem);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String key, bool isSelected) {
    final filter = filters.firstWhere((f) => f['key'] == key);

    return InkWell(
      onTap: () => _applyFilter(key),
      borderRadius: BorderRadius.circular(10),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minHeight: 40), // Tinggi minimum
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? filter['color'] : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              // Agar teks bisa wrap jika panjang
              child: Text(
                filter['displayName'],
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Image.asset(
              filter['iconAsset'],
              width: 16,
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPesananItem(PesananModel pesanan, bool isLastItem) {
    // Ambil hanya item pertama untuk ditampilkan
    final firstItem = pesanan.items.isNotEmpty ? pesanan.items[0] : null;
    final additionalItemsCount = pesanan.items.length - 1;
    final hasSingleItem = pesanan.items.length == 1;
    final hasMultipleItems = pesanan.items.length > 1;

    return Padding(
      padding: EdgeInsets.only(bottom: isLastItem ? 80 : 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Order',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "#${pesanan.orderId}",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // HANYA TAMPILKAN ITEM PERTAMA
              if (firstItem != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
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
                            imageUrl: '$baseUrlStatic/${firstItem.image}',
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstItem.namaProduk,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (pesanan.hargaRp == null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Image.asset(
                                          'assets/images/poin.png',
                                          height: 14,
                                          width: 14,
                                        ),
                                      ),
                                    Text(
                                      pesanan.hargaRp != null
                                          ? formatRupiah(firstItem.harga)
                                          : '${numberFormat.format(firstItem.harga)} Poin',
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
                                  '${firstItem.berat} ${firstItem.satuan.toLowerCase() == 'kilogram' ? 'kg' : firstItem.satuan.toLowerCase() == 'gram' ? 'gr' : firstItem.satuan}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // TOMBOL LIHAT DETAIL/SEMUA PRODUK
              if (hasSingleItem || hasMultipleItems)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GestureDetector(
                    onTap: () => _navigateToOrderDetail(pesanan),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          hasMultipleItems
                              ? 'Lihat ${additionalItemsCount} produk lainnya'
                              : 'Lihat Detail',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 5),
              const Divider(
                color: Color(0xFFF0F1F5),
                thickness: 1,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: pesanan.status == 'pending'
                          ? Colors.orange
                          : pesanan.status == 'confirmed'
                              ? const Color(0xFF74B11A)
                              : pesanan.status == 'processed'
                                  ? Colors.blue
                                  : pesanan.status == 'out-for-delivery'
                                      ? Colors.purple
                                      : pesanan.status == 'delivered'
                                          ? Colors.teal
                                          : pesanan.status == 'cancelled'
                                              ? Colors.grey
                                              : Colors.red,
                    ),
                    child: Text(
                      statusMap[pesanan.status] ?? pesanan.status,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      border: Border.all(
                        color: pesanan.paymentStatus == 'unpaid'
                            ? Colors.orange.shade700
                            : pesanan.paymentStatus == 'paid'
                                ? const Color(0xFF74B11A)
                                : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      paymentStatusMap[pesanan.paymentStatus] ??
                          pesanan.paymentStatus,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: pesanan.paymentStatus == 'unpaid'
                            ? Colors.orange.shade700
                            : pesanan.paymentStatus == 'paid'
                                ? const Color(0xFF74B11A)
                                : Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      border: Border.all(
                        color: pesanan.metodePembayaran == 'COD'
                            ? const Color(0xFFFF0FC3)
                            : pesanan.metodePembayaran == 'Poin'
                                ? const Color(0xFF591AB1)
                                : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      pesanan.metodePembayaran,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: pesanan.metodePembayaran == 'COD'
                            ? const Color(0xFFFF0FC3)
                            : pesanan.metodePembayaran == 'Poin'
                                ? const Color(0xFF591AB1)
                                : Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      if (pesanan.hargaRp == null)
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Image.asset(
                            'assets/images/poin.png',
                            height: 14,
                            width: 14,
                          ),
                        ),
                      Text(
                        pesanan.hargaRp != null
                            ? formatRupiah(pesanan.totalBayar)
                            : '${numberFormat.format(pesanan.totalBayar)} Poin',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      itemCount: 3, // Number of shimmer items
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 100,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children:
                          List.generate(2, (index) => _buildShimmerItem()),
                    ),
                    const SizedBox(height: 5),
                    const Divider(
                      color: Color(0xFFF0F1F5),
                      thickness: 1,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 60,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 60,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 50,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
            ),
            child: Container(
              height: 10,
              width: 10,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
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
  }
}
