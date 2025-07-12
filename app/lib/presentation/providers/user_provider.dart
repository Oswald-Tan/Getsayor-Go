import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:getsayor/core/api/config.dart';

class UserProvider with ChangeNotifier {
  String? _token;
  String? _username;
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

  // Getter untuk data detail user
  String? get fullname => _fullname;
  String? get phoneNumber => _phoneNumber;
  String? get photoProfile => _photoProfile;
  String? get token => _token;
  String? get username => _username;
  String? get email => _email;
  String? get role => _role;
  String? get referralCode => _referralCode;
  int? get userId => _userId;
  int? get points => _points;
  List<Map<String, dynamic>> get referrals => _referrals;
  String? get createdAt => _createdAt;
  bool get isAuthenticated => _token != null;

  // Method untuk mendapatkan data user dari server
  Future<void> getUserData(String token) async {
    const url = '$baseUrl/auth/user';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
      }).timeout(
        const Duration(seconds: 10), // Timeout 10 detik
        onTimeout: () {
          // Jika timeout terjadi, return custom response atau exception
          throw 'Connection timeout, please try again later.';
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _userId = userData['id'];
        _username = userData['username'];
        _email = userData['email'];
        _referralCode = userData['referralCode'];
        _role = userData['role'];
        _points = userData['points'];
        _referrals =
            List<Map<String, dynamic>>.from(userData['referrals'] ?? []);
        _fullname = userData['userDetails']?['fullname'] ?? 'Tidak tersedia';
        _phoneNumber =
            userData['userDetails']?['phone_number'] ?? 'Tidak tersedia';
        _photoProfile = userData['userDetails']?['photo_profile'];
        _createdAt = userData['created_at'];
        _token = token;
        // Notify listeners after the data is updated
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
