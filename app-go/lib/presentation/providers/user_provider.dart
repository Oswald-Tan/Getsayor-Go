import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:getsayor/core/api/config.dart';

class UserProvider with ChangeNotifier {
  String? _token;
  String? _email;
  String? _role;
  int? _userId;
  int? _points;
  String? _fullname;
  String? _createdAt;
  String? _referralCode;
  String? _phoneNumber;
  String? _photoProfile;
  List<Map<String, dynamic>> _referrals = [];
  int? _totalBonusLevel1;
  int? _totalBonusLevel2;

  // Getter untuk data detail user
  String? get token => _token;
  String? get email => _email;
  String? get role => _role;
  int? get userId => _userId;
  int? get points => _points;
  String? get fullname => _fullname;
  String? get createdAt => _createdAt;
  String? get referralCode => _referralCode;
  String? get phoneNumber => _phoneNumber;
  String? get photoProfile => _photoProfile;
  List<Map<String, dynamic>> get referrals => _referrals;
  int? get totalBonusLevel1 => _totalBonusLevel1;
  int? get totalBonusLevel2 => _totalBonusLevel2;
  bool get isAuthenticated => _token != null;

  Future<void> getUserData(String token) async {
    const url = '$baseUrl/auth-app/user';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw 'Connection timeout, please try again later.';
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _userId = userData['id'];
        _email = userData['email'];
        _createdAt = userData['created_at'];
        _role = userData['role'];
        _points = userData['points'];
        _referralCode = userData['referralCode'];
        _fullname = userData['fullname'] ?? 'Tidak tersedia';
        _phoneNumber = userData['phone_number'] ?? 'Tidak tersedia';
        _photoProfile = userData['photo_profile'] ?? '';
        _totalBonusLevel1 = userData['total_bonus_level1'] ?? 0;
        _totalBonusLevel2 = userData['total_bonus_level2'] ?? 0;

        // Handle referrals array
        _referrals = (userData['referrals'] as List<dynamic>?)
                ?.map((ref) => ref as Map<String, dynamic>)
                .toList() ??
            [];

        _token = token;
        notifyListeners();

        debugPrint('User data fetched successfully: $userData');
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error fetching user data: $error');
      rethrow;
    }
  }

  // Menambahkan metode untuk memperbarui username
  void updateFullname(String newFullname) {
    _fullname = newFullname;
    notifyListeners(); // Notifikasi perubahan ke listener
  }

  void updatePhoneNumber(String newPhoneNumber) {
    _phoneNumber = newPhoneNumber;
    notifyListeners(); // Notifikasi perubahan ke listener
  }

  void updateEmail(String newEmail) {
    _email = newEmail;
    notifyListeners(); // Notifikasi perubahan ke listener
  }
}
