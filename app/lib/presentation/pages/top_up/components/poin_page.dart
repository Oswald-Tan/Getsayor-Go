import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/top_up/components/poin_content.dart';
import 'package:intl/intl.dart';
import 'package:getsayor/data/model/top_up_poin_model.dart';
import 'package:getsayor/data/services/topup_service.dart';
import 'package:getsayor/data/services/harga_poin_service.dart';
import 'package:provider/provider.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:shimmer/shimmer.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

class PoinPage extends StatefulWidget {
  const PoinPage({super.key});

  @override
  State<PoinPage> createState() => _PoinPageState();
}

class _PoinPageState extends State<PoinPage> {
  final TopUpPoinService _topUpService = TopUpPoinService();
  final HargaPoinService _hargaPoinService = HargaPoinService();

  List<TopUpPoin> _allData = [];
  bool _isLoadingHistory = true;
  bool _isFiltering = false;
  int _hargaPoin = 10; // Default value
  bool _isLoadingHarga = true;
  String _selectedFilter = 'today';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _errorMessage;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchHargaPoin();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoadingHistory = true;
      _errorMessage = null; // Reset error
    });
    try {
      final data = await _topUpService.fetchTopUpPoin(context);
      setState(() {
        _allData = data;
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHistory = false;
        _errorMessage = e.toString(); // Simpan error
      });
    }
  }

  Future<void> _fetchHargaPoin() async {
    try {
      final hargaPoinModel = await _hargaPoinService.getHargaPoin(context);
      setState(() {
        _hargaPoin = hargaPoinModel.hargaPoin;
        _isLoadingHarga = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHarga = false;
      });
      print('Error fetching harga poin: $e');
    }
  }

  Future<void> _onRefresh() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _isLoadingHistory = true;
      _isLoadingHarga = true;
    });

    await Future.wait([
      _fetchData(),
      _fetchHargaPoin(),
      userProvider.getUserData(userProvider.token!),
    ]);
  }

  List<TopUpPoin> _applyFilter() {
    if (_isLoadingHistory) return [];

    switch (_selectedFilter) {
      case 'today':
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = todayStart.add(const Duration(days: 1));
        return _allData.where((item) {
          final itemDate = DateTime.parse(item.date).toLocal();
          return itemDate.isAfter(todayStart) && itemDate.isBefore(todayEnd);
        }).toList();

      case 'week':
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return _allData.where((item) {
          final itemDate = DateTime.parse(item.date).toLocal();
          return itemDate.isAfter(startOfWeek) && itemDate.isBefore(endOfWeek);
        }).toList();

      case 'month':
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 1);
        return _allData.where((item) {
          final itemDate = DateTime.parse(item.date).toLocal();
          return itemDate.isAfter(startOfMonth) &&
              itemDate.isBefore(endOfMonth);
        }).toList();

      case 'year':
        final now = DateTime.now();
        final startOfYear = DateTime(now.year, 1, 1);
        final endOfYear = DateTime(now.year + 1, 1, 1);
        return _allData.where((item) {
          final itemDate = DateTime.parse(item.date).toLocal();
          return itemDate.isAfter(startOfYear) && itemDate.isBefore(endOfYear);
        }).toList();

      case 'custom':
        if (_startDate == null || _endDate == null) return _allData;
        final customEnd = _endDate!.add(const Duration(days: 1));
        return _allData.where((item) {
          final itemDate = DateTime.parse(item.date).toLocal();
          return itemDate.isAfter(_startDate!) && itemDate.isBefore(customEnd);
        }).toList();

      default:
        return _allData;
    }
  }

  void _handleFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _isFiltering = true; // Tandai bahwa filtering sedang berlangsung
    });

    // Simulasikan proses filtering (biasanya sangat cepat)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isFiltering = false; // Selesaikan proses filtering
        });
      }
    });
  }

  void _handleCustomDateSelected(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _selectedFilter = 'custom';
      _isFiltering = true; // Tandai bahwa filtering sedang berlangsung
    });

    // Simulasikan proses filtering
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isFiltering = false; // Selesaikan proses filtering
        });
      }
    });
  }

  // Fungsi untuk menampilkan bottom sheet bantuan
  void _showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
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
              const Center(
                child: Text(
                  'Pusat Bantuan Poin',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // FAQ 1: Apa itu Poin Getsayor?
              _buildHelpItem(
                question: 'Apa itu Poin Getsayor?',
                answer:
                    'Poin Getsayor adalah mata uang digital yang dapat Anda gunakan untuk berbelanja produk-produk di aplikasi Getsayor.',
              ),

              // FAQ 2: Cara Mendapatkan Poin
              _buildHelpItem(
                question: 'Bagaimana cara mendapatkan poin?',
                answer:
                    'Anda bisa mendapatkan poin dengan top up menggunakan fitur pembelian dalam aplikasi (In-App Purchase) melalui Google Play.',
              ),

              // FAQ 3: Cara Menggunakan Poin
              _buildHelpItem(
                question: 'Bagaimana cara menggunakan poin?',
                answer:
                    'Poin dapat digunakan saat checkout atau pembelian produk dengan memilih opsi Bayar dengan "Poin". Anda akan melihat jumlah poin yang diperlukan untuk membeli produk tersebut.',
              ),

              // FAQ 4: Konversi Poin
              _buildHelpItem(
                question: 'Berapa nilai tukar poin ke Rupiah?',
                answer:
                    'Nilai tukar poin dapat berubah sesuai kebijakan Getsayor. Anda dapat melihat nilai tukar terkini di bagian "Konversi Poin" pada halaman ini.',
              ),

              // FAQ 5: Riwayat Transaksi
              _buildHelpItem(
                question: 'Bagaimana cara melihat riwayat top up?',
                answer:
                    'Semua riwayat top up poin Anda dapat dilihat di bagian "Riwayat Top Up" pada halaman ini.',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHelpItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF1F2131),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF555555),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _applyFilter();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Poin Saya',
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
            icon: const Icon(Icons.help_outline),
            color: const Color(0xFF1F2131),
            onPressed: () => _showHelpBottomSheet(context),
          ),
        ],
      ),
      backgroundColor: const Color(0XFFF5F5F5),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _onRefresh,
        color: const Color(0xFF74B11A),
        backgroundColor: Colors.white,
        child: _isLoadingHistory
            ? const Center(child: CircularProgressIndicator())
            : PoinContent(
                scrollController: _scrollController,
                fetchData: Future.value(filteredData),
                hargaPoin: _hargaPoin,
                isLoadingHarga: _isLoadingHarga,
                onRefresh: _onRefresh,
                selectedFilter: _selectedFilter,
                startDate: _startDate,
                endDate: _endDate,
                onFilterChanged: _handleFilterChanged,
                onCustomDateSelected: _handleCustomDateSelected,
                isFiltering: _isFiltering,
                errorMessage: _errorMessage,
              ),
      ),
    );
  }
}

// Helper shimmer widget
Widget shimmerBox({required double width}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      width: width,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}

class TopUpPoinCardShimmer extends StatelessWidget {
  const TopUpPoinCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100,
                  height: 12,
                  color: Colors.white,
                ),
                Container(
                  width: 70,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 150,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 100,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
