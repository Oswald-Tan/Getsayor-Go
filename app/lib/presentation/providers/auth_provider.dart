import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onepref/onepref.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Untuk penyimpanan token
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/presentation/providers/user_provider.dart'; // Pastikan UserProvider sudah di-import

class AuthProvider with ChangeNotifier {
  String? _token;
  final Dio _dio = Dio();

  // Cek apakah user sudah login berdasarkan token
  bool get isAuthenticated => _token != null;

  String? get token => _token;

  // Simpan token ke SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    // Simpan juga ke OnePref untuk konsistensi
    await OnePref.setString('token', token);

    _token = token;
    notifyListeners();

    debugPrint("Token saved to SharedPreferences and OnePref");
  }

  Future<void> updateFcmToken(String token) async {
    try {
      print('[FCM] Updating token to backend: $token');
      final response = await _dio.patch(
        '$baseUrl/auth/update-fcm',
        data: {'fcm_token': token},
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${_token}', // 👈 Gunakan token JWT dari AuthProvider
          },
        ),
      );
      print('[FCM] Update success: ${response.data}');
    } catch (e) {
      debugPrint('Error update FCM: $e');
    }
  }

  // Fungsi logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); //ambil token dari penyimpanan

    if (token != null) {
      //kirim request logout ke backend
      final url = Uri.parse('$baseUrl/auth/logout');

      try {
        final res = await http.post(
          url,
          headers: {
            'Authorization':
                'Bearer $token', //kirim token pada header authorization
          },
        );

        if (res.statusCode == 200) {
          //berhasil logout, hapus token dari penyimpanan
          await prefs.remove('token');
          OnePref.setString('token', ''); // Tambahkan ini
          OnePref.setString('userId', ''); // Jangan lupa hapus userId juga
          _token = null;
          notifyListeners(); //notifikasi perubahan untuk memperbarui UI
        } else {
          debugPrint('Logout failed: ${res.body}');
        }
      } catch (error) {
        debugPrint('Error: $error');
      }
    }
  }

  Future<String?> registerUser({
    required String fullname,
    required String password,
    required String email,
    required String roleName,
    required String phoneNumber,
    String? referralCode, // Tambahkan field opsional untuk referral code
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    try {
      // Buat body request
      final requestBody = {
        'fullname': fullname,
        'password': password,
        'email': email,
        'phone_number': phoneNumber,
        'role_name': roleName,
      };

      // Jika referralCode ada, tambahkan ke body request
      if (referralCode != null && referralCode.isNotEmpty) {
        requestBody['referralCode'] = referralCode;
      }

      final res = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 10), // Timeout 10 detik
        onTimeout: () {
          // Jika timeout terjadi, return custom response atau exception
          throw 'Connection timeout, please try again later.';
        },
      );

      if (res.statusCode == 201) {
        // Registrasi berhasil
        return null;
      } else {
        // Tangkap pesan error dari API
        final responseBody = jsonDecode(res.body);
        return responseBody['message'];
      }
    } catch (error) {
      debugPrint('Error: $error');
      return 'Internal server error. Please try again later.';
    }
  }

  // Login pengguna dan simpan token
  Future<bool> loginUser({
    required String email,
    required String password,
    required UserProvider userProvider,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final res = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(
        const Duration(seconds: 10), // Timeout 10 detik
        onTimeout: () {
          // Jika timeout terjadi, return custom response atau exception
          throw 'Connection timeout, please try again later.';
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['token'];
        debugPrint('Login successful');

        // 1. Simpan auth token terlebih dahulu
        await _saveToken(token);

        // 2. Update FCM token setelah auth token tersimpan
        await _getAndUpdateFcmToken();

        // 3. Ambil data user
        await userProvider.getUserData(token);

        // Simpan userId ke OnePref jika tersedia
        if (userProvider.userId != null) {
          await OnePref.setString('userId', userProvider.userId!.toString());
          debugPrint('Saved userId: ${userProvider.userId}');
        } else {
          debugPrint('Warning: userId is null in userProvider');
        }

        return true;
      } else {
        // Tangkap pesan kesalahan dari backend
        final errorData = jsonDecode(res.body);
        final errorMessage = errorData['message'] ?? 'Login failed';
        debugPrint('Failed to login: $errorMessage');
        throw errorMessage;
      }
    } catch (error) {
      // print('Error: $error');
      rethrow;
    }
  }

  Future<void> _requestFcmPermission() async {
    try {
      if (Platform.isIOS) {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false, // Non-provisional permission
        );

        debugPrint('Permission status: ${settings.authorizationStatus}');
      }
    } catch (e) {
      debugPrint('Error requesting permission: $e');
    }
  }

  Future<void> _getAndUpdateFcmToken({int retryCount = 3}) async {
    int attempt = 0;
    while (attempt < retryCount) {
      try {
        await _requestFcmPermission();
        String? fcmToken = await FirebaseMessaging.instance.getToken();

        if (fcmToken != null) {
          debugPrint('FCM Token obtained: $fcmToken');
          await updateFcmToken(fcmToken);
          return;
        }

        await Future.delayed(Duration(seconds: 2));
        attempt++;
      } catch (e) {
        debugPrint('Attempt ${attempt + 1} failed: $e');
        attempt++;
      }
    }
    debugPrint('Failed to get FCM token after $retryCount attempts');
  }

  // Muat token ketika aplikasi dimulai
  Future<void> initialize() async {
    // Muat token dari OnePref saat inisialisasi
    _token = OnePref.getString('token');
    // Jika tidak ada di OnePref, coba dari SharedPreferences
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');

      // Jika ada di SharedPreferences, simpan ke OnePref
      if (_token != null) {
        OnePref.setString('token', _token!);
      }
    }

    notifyListeners();

    // Listen token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('[FCM] Token refreshed: $newToken');
      if (_token != null) {
        // Hanya update jika user sudah login
        await updateFcmToken(newToken);
      }
    });
  }
}
