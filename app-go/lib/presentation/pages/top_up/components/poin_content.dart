import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getsayor/data/model/top_up_poin_model.dart';
import 'package:getsayor/presentation/pages/home/components/card_saldo_poin.dart';
import 'package:getsayor/presentation/pages/top_up/components/topup_poin_card.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

class PoinContent extends StatelessWidget {
  final Future<List<TopUpPoin>> fetchData;
  final ScrollController scrollController;
  final int hargaPoin;
  final bool isLoadingHarga;
  final Future<void> Function() onRefresh;
  final String selectedFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String) onFilterChanged;
  final Function(DateTime, DateTime) onCustomDateSelected;
  final bool isFiltering;
  final String? errorMessage;

  const PoinContent({
    super.key,
    required this.fetchData,
    required this.scrollController,
    required this.hargaPoin,
    required this.isLoadingHarga,
    required this.onRefresh,
    required this.selectedFilter,
    required this.startDate,
    required this.endDate,
    required this.onFilterChanged,
    required this.onCustomDateSelected,
    required this.isFiltering,
    required this.errorMessage,
  });

  Widget _buildErrorWidget(String errorMessage) {
    String imagePath;
    String title;
    String description;

    if (errorMessage.contains('Timeout') ||
        errorMessage.contains('timeout') ||
        errorMessage.contains('koneksi')) {
      imagePath = 'assets/images/no-internet.png';
      title = 'Koneksi Terputus';
      description = 'Periksa koneksi internet Anda dan coba lagi';
    } else if (errorMessage.contains('Server') ||
        errorMessage.contains('server')) {
      imagePath = 'assets/images/no-internet.png';
      title = 'Server Bermasalah';
      description = 'Terjadi gangguan pada server. Coba beberapa saat lagi';
    } else {
      imagePath = 'assets/images/no-internet.png';
      title = 'Gagal Memuat Data';
      description = errorMessage;
    }

    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF74B11A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, String text, String value) {
    final isSelected = selectedFilter == value;
    final iconData = _getIconForFilter(value);

    return GestureDetector(
      onTap: () => onFilterChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF74B11A) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF74B11A) : const Color(0xFFE8E8E8),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF666666),
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForFilter(String filter) {
    switch (filter) {
      case 'today':
        return Icons.today;
      case 'week':
        return Icons.view_week;
      case 'month':
        return Icons.calendar_month;
      case 'year':
        return Icons.date_range;
      default:
        return Icons.date_range;
    }
  }

  Widget _buildCustomDateButton(BuildContext context) {
    final isSelected = selectedFilter == 'custom';

    return GestureDetector(
      onTap: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          initialDateRange: startDate != null && endDate != null
              ? DateTimeRange(start: startDate!, end: endDate!)
              : null,
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF74B11A), // Warna utama hijau
                  onPrimary: Colors.white, // Warna teks di atas primary
                  surface: Colors.white, // Warna latar dialog
                  onSurface: Colors.black, // Warna teks utama
                ), // Pastikan latar dialog putih
                textTheme: Theme.of(context).textTheme.copyWith(
                      bodyLarge: const TextStyle(color: Colors.black87),
                      bodyMedium: const TextStyle(color: Colors.black87),
                      titleMedium: const TextStyle(color: Colors.black87),
                      labelLarge: const TextStyle(color: Colors.white),
                    ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor:
                        const Color(0xFF74B11A), // Warna teks button
                  ),
                ),
                dialogTheme:
                    const DialogThemeData(backgroundColor: Colors.white),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          onCustomDateSelected(picked.start, picked.end);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF74B11A) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF74B11A) : const Color(0xFFE8E8E8),
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.calendar_today,
          size: 18,
          color: isSelected ? Colors.white : const Color(0xFF666666),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Balance Card
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 16),
            child: SizedBox(
              height: 125,
              child: CardSaldoPoin(),
            ),
          ),
        ),

        // Point Conversion Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF0F3F9),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEAECF0),
                  width: 1,
                ),
              ),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final balance = userProvider.points ?? 0;
                  final isUserLoading = userProvider.points == null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFEF6E6),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  FontAwesomeIcons.arrowRightArrowLeft,
                                  color: Color(0xFFD4A017),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Konversi Poin',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF1D2939),
                                ),
                              ),
                            ],
                          ),
                          isLoadingHarga || isUserLoading
                              ? modernShimmerBox(width: 150)
                              : Text(
                                  '1 Poin = Rp ${NumberFormat('#,##0').format(hargaPoin)}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF667085),
                                  ),
                                ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(
                          height: 1, thickness: 1, color: Color(0xFFF0F2F5)),
                      const SizedBox(height: 16),

                      // Balance Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.wallet,
                                color: Color(0xFF98A2B3),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Nilai Saldo Setara',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF1D2939),
                                ),
                              ),
                            ],
                          ),
                          isLoadingHarga || isUserLoading
                              ? modernShimmerBox(width: 120)
                              : Text(
                                  'Rp ${NumberFormat('#,##0').format(balance * hargaPoin)}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1D2939),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        // Modern History Section Header
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Riwayat Top Up',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),

        // Modern Filter Buttons
        SliverToBoxAdapter(
          child: Container(
            margin:
                const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton(context, 'Hari Ini', 'today'),
                  const SizedBox(width: 8),
                  _buildFilterButton(context, 'Minggu Ini', 'week'),
                  const SizedBox(width: 8),
                  _buildFilterButton(context, 'Bulan Ini', 'month'),
                  const SizedBox(width: 8),
                  _buildFilterButton(context, 'Tahun Ini', 'year'),
                  const SizedBox(width: 8),
                  _buildCustomDateButton(context),
                ],
              ),
            ),
          ),
        ),

        // Custom Date Range Display
        if (selectedFilter == 'custom' && startDate != null && endDate != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF74B11A).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF74B11A).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.date_range_rounded,
                      color: Color(0xFF74B11A),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Periode: ${DateFormat('dd MMM yyyy').format(startDate!)} - ${DateFormat('dd MMM yyyy').format(endDate!)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF74B11A),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Content based on state
        if (errorMessage != null && !isFiltering)
          SliverToBoxAdapter(
            child: _buildErrorWidget(errorMessage!),
          )
        else if (isFiltering)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ModernTopUpPoinCardShimmer(),
                );
              },
              childCount: 5,
            ),
          )
        else
          FutureBuilder<List<TopUpPoin>>(
            future: fetchData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return const Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: ModernTopUpPoinCardShimmer(),
                      );
                    },
                    childCount: 5,
                  ),
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: _buildErrorWidget(snapshot.error.toString()),
                );
              }

              final data = snapshot.data ?? [];

              if (data.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 60, horizontal: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/nodata.png',
                            height: 130,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Belum Ada Riwayat',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Belum ada riwayat top up pada periode yang dipilih',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey[600],
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TopUpPoinCard(
                      history: data[index],
                      hargaPoinPerPoint: hargaPoin,
                    ),
                  ),
                  childCount: data.length,
                ),
              );
            },
          ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }
}

// Modern shimmer components
Widget modernShimmerBox({required double width}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

class ModernTopUpPoinCardShimmer extends StatelessWidget {
  const ModernTopUpPoinCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 160,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 100,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
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
