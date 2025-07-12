import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:getsayor/data/model/afiliasi_bonus_model.dart';
import 'package:getsayor/data/services/afiliasi_bonus_service.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

final currencyFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

String formatRupiah(int value) {
  return currencyFormat.format(value).replaceAll('Rp', 'Rp. ');
}

class AvailableRewardsPage extends StatefulWidget {
  const AvailableRewardsPage({super.key});

  @override
  State<AvailableRewardsPage> createState() => _AvailableRewardsPageState();
}

class _AvailableRewardsPageState extends State<AvailableRewardsPage> {
  final AfiliasiBonusService _afiliasiBonusService = AfiliasiBonusService();

  String? _errorMessage;
  bool _isLoading = true;
  bool _isRefreshing = false;
  List<AfiliasiBonus> _pendingBonuses = [];

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
      final bonuses = await _afiliasiBonusService.getPendingBonuses(context);
      setState(() {
        _pendingBonuses = bonuses;
        _errorMessage = null;
      });
    } on TimeoutException catch (_) {
      setState(() {
        _errorMessage =
            'Request timeout. Please check your internet connection';
      });
    } on SocketException catch (_) {
      setState(() {
        _errorMessage = 'No internet connection. Please check your network';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      final bonuses = await _afiliasiBonusService.getPendingBonuses(context);
      setState(() {
        _pendingBonuses = bonuses;
        _errorMessage = null;
      });
    } on TimeoutException catch (_) {
      setState(() {
        _errorMessage =
            'Request timeout. Please check your internet connection';
      });
    } on SocketException catch (_) {
      setState(() {
        _errorMessage = 'No internet connection. Please check your network';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _claimBonus(int bonusId) async {
    try {
      await _afiliasiBonusService.claimBonus(context, bonusId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bonus berhasil diklaim!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      setState(() {
        _pendingBonuses.removeWhere((bonus) => bonus.id == bonusId);
      });
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceAll('Exception:', '').trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  Widget _buildErrorWidget(String errorMessage) {
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
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFFF7043),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Failed to Load Rewards",
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
                errorMessage,
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
            (index) => _buildRewardShimmer(),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 20,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 14,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(AfiliasiBonus bonus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9E7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Color(0xFF74B11A),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonus Referral',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(bonus.bonusAmount),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF74B11A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expiry: ${DateFormat('MMM d, yyyy').format(DateTime.parse(bonus.expiryDate))}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 36,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bonus.status == 'pending'
                    ? const Color(0xFF74B11A)
                    : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: bonus.status == 'pending'
                  ? () => _claimBonus(bonus.id)
                  : null,
              child: Text(
                'Klaim',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: bonus.status == 'pending'
                      ? Colors.white
                      : Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            child: const Icon(
              Icons.card_giftcard,
              size: 48,
              color: Color(0xFF3D5CFF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Rewards Available",
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
              "You don't have any rewards to claim at the moment. Refer more friends to earn rewards!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF6E7FAA),
                height: 1.5,
              ),
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
        title: const Text(
          'Available Rewards',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF1F2131),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildShimmerLoading()
          : _errorMessage != null
              ? _buildErrorWidget(_errorMessage!)
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: const Color(0xFF74B11A),
                  backgroundColor: Colors.white,
                  child: _pendingBonuses.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height,
                            ),
                            child: _buildEmptyState(),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.builder(
                            itemCount: _pendingBonuses.length,
                            itemBuilder: (context, index) {
                              return _buildRewardCard(_pendingBonuses[index]);
                            },
                          ),
                        ),
                ),
    );
  }
}
