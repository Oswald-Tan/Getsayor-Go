import 'dart:async';
import 'package:getsayor/presentation/pages/bonus/components/AvailableRewardsPage%20.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  String? _errorMessage;
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.getUserData(userProvider.token!);
    } on SocketException catch (_) {
      setState(() {
        _errorMessage = 'No internet connection. Please check your network';
      });
    } on TimeoutException catch (_) {
      setState(() {
        _errorMessage = 'Request timeout. Please try again later';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load referral data. Please try again';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _errorMessage = null;
      _isRefreshing = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.getUserData(userProvider.token!);
    } on SocketException catch (_) {
      setState(() {
        _errorMessage = 'No internet connection. Please check your network';
      });
    } on TimeoutException catch (_) {
      setState(() {
        _errorMessage = 'Request timeout. Please try again later';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load referral data. Please try again';
      });
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _shareReferralCode(String referralCode) {
    if (referralCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Referral code is not available'),
        ),
      );
      return;
    }

    const appUrl = "https://getsayor.com";
    final message =
        "Yuk mulai belanja kebutuhan dapur dengan mudah lewat aplikasi Get Sayor!\n\n"
        "🆔 Gunakan kode referral: *$referralCode*\n\n"
        "📌 Klik tautan berikut untuk informasi lebih lanjut dan daftar: $appUrl\n\n"
        "Ayo dukung belanja sayur lokal dengan lebih mudah! 🛒";

    Share.share(
      message,
      subject: 'GetSayor Referral Code',
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FD),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E7FF), width: 1),
              ),
              child: const FaIcon(
                FontAwesomeIcons.triangleExclamation,
                size: 48,
                color: Color(0xFFFF7043),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Failed to Load Referrals",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2131),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                _errorMessage ?? 'An unknown error occurred',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF6E7FAA),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D5CFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text(
                "Try Again",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(
            3,
            (index) => _buildShimmerCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        title: Container(
          height: 18,
          width: double.infinity,
          color: Colors.white,
        ),
        subtitle: Container(
          height: 14,
          width: 100,
          color: Colors.white,
          margin: const EdgeInsets.only(top: 8),
        ),
        trailing: Container(
          width: 20,
          height: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildReferralList(UserProvider userProvider) {
    // Format currency untuk Indonesia
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Hitung total bonus dari semua referrals level 1
    final totalMonthlyBonusLevel1 =
        userProvider.referrals.fold<int>(0, (sum, referral) {
      return sum + (referral['monthly_bonus'] as int? ?? 0);
    });

    return Column(
      children: [
        // Grid Container untuk Total Bonus Level 1 dan Level 2
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              // Total Bonus Level 1 - Kiri
              Expanded(
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
                      // Icon di kiri atas
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.coins,
                            size: 16,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Teks di bawah icon
                      const Text(
                        'Total Bonus Level 1',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF6E7FAA),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(totalMonthlyBonusLevel1),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2131),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dari ${userProvider.referrals.length} referral langsung',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: Color(0xFF6E7FAA),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Total Bonus Level 2 - Kanan (hanya ditampilkan jika ada)
              if (userProvider.totalBonusLevel2 != null &&
                  userProvider.totalBonusLevel2! > 0)
                Expanded(
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
                        // Icon di kiri atas
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: FaIcon(
                              FontAwesomeIcons.crown,
                              size: 16,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Teks di bawah icon
                        const Text(
                          'Total Bonus Level 2',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF6E7FAA),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(userProvider.totalBonusLevel2),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2131),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Dari referral tingkat kedua',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Color(0xFF6E7FAA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Informasi klaim bonus (jika ada bonus)
        if ((totalMonthlyBonusLevel1 > 0 ||
            (userProvider.totalBonusLevel2 ?? 0) > 0))
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3D5CFF), width: 1),
            ),
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.circleInfo,
                  size: 16,
                  color: Color(0xFF3D5CFF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Total bonus dapat diklaim: ${currencyFormat.format(totalMonthlyBonusLevel1 + (userProvider.totalBonusLevel2 ?? 0))}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const AvailableRewardsPage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D5CFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "Klaim Semua",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // List Referrals (hanya level 1)
        Expanded(
          child: ListView.builder(
            itemCount: userProvider.referrals.length,
            itemBuilder: (context, index) {
              final referral = userProvider.referrals[index];
              final referralUsedAt = referral['referral_used_at'];
              final fullname =
                  referral['fullname'] as String? ?? 'Unknown User';
              final monthlySpent = referral['monthly_spent'] as int? ?? 0;
              final monthlyBonus = referral['monthly_bonus'] as int? ?? 0;
              final monthlyBonusLevel2 =
                  referral['monthly_bonus_level2'] as int? ?? 0;
              final isEligibleForBonus =
                  referral['is_eligible_for_bonus'] as bool? ?? false;
              final eligibleOrdersCount =
                  referral['eligible_orders'] as int? ?? 0;

              return ReferralCard(
                fullname: fullname,
                date: referralUsedAt != null
                    ? DateTime.parse(referralUsedAt)
                    : null,
                monthlySpent: monthlySpent,
                monthlyBonus: monthlyBonus,
                monthlyBonusLevel2: monthlyBonusLevel2,
                isEligibleForBonus: isEligibleForBonus,
                eligibleOrders: eligibleOrdersCount,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (_isRefreshing || _isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2131)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Referrals',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2131),
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: _buildShimmerLoading(),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2131)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Referrals',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2131),
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: _buildErrorWidget(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2131)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Referrals',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2131),
          ),
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0XFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF74B11A),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: userProvider.referrals.isEmpty
                    ? EmptyReferralsWidget(
                        referralCode: userProvider.referralCode ?? '',
                        onSharePressed: _shareReferralCode,
                      )
                    : _buildReferralList(userProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReferralCard extends StatefulWidget {
  final String fullname;
  final DateTime? date;
  final int monthlySpent;
  final int monthlyBonus;
  final int monthlyBonusLevel2;
  final bool isEligibleForBonus;
  final int eligibleOrders; // Tambahkan parameter baru

  const ReferralCard({
    super.key,
    required this.fullname,
    this.date,
    required this.monthlySpent,
    required this.monthlyBonus,
    required this.monthlyBonusLevel2,
    required this.isEligibleForBonus,
    required this.eligibleOrders, // Parameter baru
  });

  @override
  State<ReferralCard> createState() => _ReferralCardState();
}

class _ReferralCardState extends State<ReferralCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: widget.isEligibleForBonus
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFF1F5FD),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: FaIcon(
                  widget.isEligibleForBonus
                      ? FontAwesomeIcons.circleCheck
                      : FontAwesomeIcons.clock,
                  size: 20,
                  color: widget.isEligibleForBonus
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF3D5CFF),
                ),
              ),
            ),
            title: Text(
              widget.fullname,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2131),
              ),
            ),
            subtitle: widget.date != null
                ? Text(
                    'Joined ${DateFormat.yMMMd().format(widget.date!)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xFF6E7FAA),
                    ),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hanya tampilkan jumlah jika >= 200.000
                    if (widget.monthlySpent >= 200000)
                      Text(
                        currencyFormat.format(widget.monthlySpent),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: widget.isEligibleForBonus
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF6E7FAA),
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      const Text(
                        '--',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Color(0xFF6E7FAA),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isEligibleForBonus ? 'Eligible' : 'Pending',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: widget.isEligibleForBonus
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF6E7FAA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF6E7FAA),
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              child: Column(
                children: [
                  const Divider(height: 1, color: Color(0xFFE0E7FF)),
                  const SizedBox(height: 12),

                  // Status Pesanan
                  _buildDetailRow(
                    icon: FontAwesomeIcons.truck,
                    iconColor: const Color(0xFF3D5CFF),
                    title: 'Status Pesanan',
                    value: 'Delivered',
                    valueColor: const Color(0xFF4CAF50),
                    isBold: true,
                  ),
                  const SizedBox(height: 8),

                  // Total Belanja Delivered
                  _buildDetailRow(
                    icon: FontAwesomeIcons.shoppingCart,
                    iconColor: const Color(0xFF3D5CFF),
                    title: 'Total Belanja Delivered',
                    value: widget.monthlySpent >= 200000
                        ? currencyFormat.format(widget.monthlySpent)
                        : 'Belum mencapai minimum',
                    valueColor: widget.monthlySpent >= 200000
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF1F2131),
                    isBold: widget.monthlySpent >= 200000,
                  ),
                  const SizedBox(height: 8),

                  // Minimum Belanja
                  _buildDetailRow(
                    icon: FontAwesomeIcons.scaleBalanced,
                    iconColor: const Color(0xFFFF9800),
                    title: 'Minimum Belanja',
                    value: 'Rp 200.000',
                    valueColor: const Color(0xFF1F2131),
                    isBold: false,
                  ),
                  const SizedBox(height: 8),

                  // Jumlah Transaksi Eligible
                  if (widget.eligibleOrders > 0)
                    _buildDetailRow(
                      icon: FontAwesomeIcons.receipt,
                      iconColor: const Color(0xFF9C27B0),
                      title: 'Transaksi Eligible',
                      value: '${widget.eligibleOrders} pesanan',
                      valueColor: const Color(0xFF9C27B0),
                      isBold: true,
                    ),

                  if (widget.eligibleOrders > 0) const SizedBox(height: 8),

                  if (widget.isEligibleForBonus) ...[
                    // Bonus Level 1
                    _buildDetailRow(
                      icon: FontAwesomeIcons.coins,
                      iconColor: const Color(0xFF4CAF50),
                      title: 'Bonus Level 1 (10%)',
                      value: currencyFormat.format(widget.monthlyBonus),
                      valueColor: const Color(0xFF4CAF50),
                      isBold: true,
                    ),
                    const SizedBox(height: 8),

                    if (widget.monthlyBonusLevel2 > 0)
                      _buildDetailRow(
                        icon: FontAwesomeIcons.crown,
                        iconColor: const Color(0xFFFF9800),
                        title: 'Bonus Level 2 (5%)',
                        value: currencyFormat.format(widget.monthlyBonusLevel2),
                        valueColor: const Color(0xFFFF9800),
                        isBold: true,
                      ),
                  ],

                  // Informasi Eligibility
                  if (!widget.isEligibleForBonus)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFFF9800), width: 1),
                      ),
                      child: Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.infoCircle,
                            size: 14,
                            color: Color(0xFFFF9800),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.monthlySpent < 200000
                                  ? 'Belum mencapai minimum belanja Rp 200.000 untuk mendapatkan bonus'
                                  : 'Menunggu pesanan delivered untuk mendapatkan bonus',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        FaIcon(icon, size: 14, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Color(0xFF6E7FAA),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: valueColor,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class EmptyReferralsWidget extends StatelessWidget {
  final String referralCode;
  final Function(String) onSharePressed;

  const EmptyReferralsWidget({
    super.key,
    required this.referralCode,
    required this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5FD),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E7FF), width: 1),
            ),
            child: const FaIcon(
              FontAwesomeIcons.userGroup,
              size: 48,
              color: Color(0xFF3D5CFF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Referrals Yet",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2131),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "You haven't referred any friends yet. Share your referral code to earn rewards! Get 10% bonus from your friend's monthly shopping (min. Rp 200,000)",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF6E7FAA),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => onSharePressed(referralCode),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D5CFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: const Text(
              "Share Referral Code",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
