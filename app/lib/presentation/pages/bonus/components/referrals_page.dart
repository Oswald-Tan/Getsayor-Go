import 'dart:async';

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

  // Fungsi untuk membagikan referral code
  void _shareReferralCode(String referralCode) {
    if (referralCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Referral code is not available'),
        ),
      );
      return;
    }

    final message =
        "Join me on GetSayor! Use my referral code: $referralCode to sign up and get rewards. Download the app now!";

    Share.share(
      message,
      subject: 'GetSayor Referral Code',
    );
  }

  // Di dalam class _ReferralPageState
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, thickness: 0.5),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return _buildShimmerCard();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
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
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 0.5,
      ),
      itemCount: userProvider.referrals.length,
      itemBuilder: (context, index) {
        final referral = userProvider.referrals[index];
        final referralUsedAt = referral['referralUsedAt'];
        final userDetails = referral['userDetails'] as Map<String, dynamic>?;
        final fullname = userDetails?['fullname'] as String? ?? 'Unknown User';

        return ReferralCard(
          fullname: fullname,
          date: referralUsedAt != null ? DateTime.parse(referralUsedAt) : null,
        );
      },
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
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2131),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: _buildErrorWidget(), // Panggil widget error yang diperbarui
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
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2131),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
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

class ReferralCard extends StatelessWidget {
  final String fullname;
  final DateTime? date;

  const ReferralCard({
    super.key,
    required this.fullname,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
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
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5FD),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.user,
              size: 20,
              color: Color(0xFF3D5CFF),
            ),
          ),
        ),
        title: Text(
          fullname,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2131),
          ),
        ),
        subtitle: date != null
            ? Text(
                'Joined ${DateFormat.yMMMd().format(date!)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Color(0xFF6E7FAA),
                ),
              )
            : const Text(
                'Pending',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.orange,
                ),
              ),
        trailing: const FaIcon(
          FontAwesomeIcons.circleCheck,
          size: 20,
          color: Color(0xFF4CAF50),
        ),
      ),
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
              "You haven't referred any friends yet. Share your referral code to earn rewards!",
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
