import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getsayor/data/model/top_up_poin_model.dart';
import 'package:getsayor/presentation/pages/home/components/card_saldo_poin.dart';
import 'package:getsayor/presentation/pages/top_up/components/buy_points.dart';
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

    // Deteksi jenis error berdasarkan pesan
    if (errorMessage.contains('Timeout') ||
        errorMessage.contains('timeout') ||
        errorMessage.contains('koneksi')) {
      imagePath = 'assets/images/no-internet.png';
      title = 'Masalah Koneksi';
      description = 'Periksa koneksi internet Anda dan pastikan sinyal stabil.';
    } else if (errorMessage.contains('Server') ||
        errorMessage.contains('server')) {
      imagePath =
          'assets/images/no-internet.png'; // Ganti dengan gambar server error jika ada
      title = 'Server Bermasalah';
      description =
          'Server sedang mengalami gangguan. Silakan coba beberapa saat lagi.';
    } else {
      imagePath = 'assets/images/no-internet.png'; // Gambar untuk error umum
      title = 'Gagal Memuat Data';
      description = errorMessage;
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.grey[700],
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
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
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

  Widget _buildFilterButton(BuildContext context, String text, String value) {
    final isSelected = selectedFilter == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onFilterChanged(value),
          borderRadius: BorderRadius.circular(20),
          splashColor: const Color(0xFF74B11A).withOpacity(0.1),
          highlightColor: const Color(0xFF74B11A).withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF74B11A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF74B11A)
                    : const Color(0xFFE5E5E5),
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
                    color: isSelected ? Colors.white : const Color(0xFF555555),
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

  // Helper method untuk custom filter
  Widget _buildCustomFilterButton(BuildContext context) {
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
          onCustomDateSelected(picked.start, picked.end);
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFF74B11A).withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF74B11A).withOpacity(0.1),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(FontAwesomeIcons.arrowRightArrowLeft,
                                  color: Color(0xFF74B11A), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Konversi Poin',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF1F2131),
                                ),
                              ),
                            ],
                          ),
                          isLoadingHarga || isUserLoading
                              ? shimmerBox(width: 150)
                              : Text(
                                  '1 Poin = Rp ${NumberFormat('#,##0').format(hargaPoin)}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(
                          height: 1, thickness: 1, color: Color(0xFFE5E5E5)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(FontAwesomeIcons.wallet,
                                  color: Color(0xFF74B11A), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Nilai Saldo Setara',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF1F2131),
                                ),
                              ),
                            ],
                          ),
                          isLoadingHarga || isUserLoading
                              ? shimmerBox(width: 120)
                              : Text(
                                  'Rp ${NumberFormat('#,##0').format(balance * hargaPoin)}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2131),
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

        // History Section
        const SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Riwayat Top Up',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  _buildCustomFilterButton(context),
                ],
              ),
            ),
          ),
        ),
        if (selectedFilter == 'custom' && startDate != null && endDate != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Rentang: ${DateFormat('dd MMM yyyy').format(startDate!)} - ${DateFormat('dd MMM yyyy').format(endDate!)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF555555),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        if (errorMessage != null && !isFiltering)
          SliverToBoxAdapter(
            child: _buildErrorWidget(errorMessage!),
          )
        else if (isFiltering)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TopUpPoinCardShimmer(),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TopUpPoinCardShimmer(),
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
                        vertical: 40, horizontal: 16),
                    child: Center(
                      child: Column(
                        children: [
                          Image.asset('assets/images/nodata.png', height: 120),
                          const SizedBox(height: 24),
                          const Text(
                            'Tidak ada riwayat pada filter yang dipilih',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                              fontSize: 16,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          child: SizedBox(height: 20),
        ),
      ],
    );
  }
}

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
