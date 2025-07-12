import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/data/model/afiliasi_bonus_model.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:provider/provider.dart';

class AfiliasiBonusService {
  final Dio _dio = Dio();

  // Fungsi untuk mengambil bonus yang pending
  Future<List<AfiliasiBonus>> getPendingBonuses(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.get(
        '$baseUrl/afiliasi-bonus-app/pending/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 10), // Tambahkan timeout
          receiveTimeout: const Duration(seconds: 10), // Tambahkan timeout
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['pendingBonus'];
        return data.map((json) => AfiliasiBonus.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch pending bonuses. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Klasifikasi error berdasarkan type
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw TimeoutException(
              'Request timeout. Please check your internet connection');

        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 404) {
            return []; // Data kosong bukan error
          } else {
            throw Exception('Server error: ${e.response?.statusCode}');
          }

        case DioExceptionType.cancel:
          throw Exception('Request cancelled');

        case DioExceptionType.unknown:
        default:
          if (e.error is SocketException) {
            throw Exception(
                'No internet connection. Please check your network');
          } else {
            throw Exception('Network error: ${e.message}');
          }
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout. Please try again');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<AfiliasiBonus>> getExpiredBonuses(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw Exception('User not authenticated.');
      }

      // Tambahkan timeout khusus
      final response = await _dio.get(
        '$baseUrl/afiliasi-bonus-app/expired/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 10), // Timeout pengiriman
          receiveTimeout: const Duration(seconds: 10), // Timeout penerimaan
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['expiredBonus'];
        return data.map((json) => AfiliasiBonus.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch expired bonuses. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Klasifikasi error berdasarkan type
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw TimeoutException(
              'Request timeout. Please check your internet connection');

        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 404) {
            return []; // Data kosong bukan error
          } else {
            throw Exception('Server error: ${e.response?.statusCode}');
          }

        case DioExceptionType.cancel:
          throw Exception('Request cancelled');

        case DioExceptionType.unknown:
        default:
          if (e.error is SocketException) {
            throw Exception('No internet connection');
          } else {
            throw Exception('Network error: ${e.message}');
          }
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout. Please try again');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Fungsi untuk klaim bonus
  Future<void> claimBonus(BuildContext context, int bonusId) async {
    try {
      // Ambil token dari UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      // Validasi token
      if (token == null) {
        throw Exception('User not authenticated.');
      }

      // Request ke API untuk klaim bonus
      final response = await _dio.post(
        '$baseUrl/afiliasi-bonus-app/claim',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) {
            // Mengijinkan status kode 400 untuk tetap diterima
            return status! < 500;
          },
        ),
        data: json.encode({'bonusId': bonusId}),
      );

      // Cek status response
      if (response.statusCode == 200) {
        debugPrint('Bonus claimed successfully.');
      } else {
        final message = response.data['message'] ?? 'Failed to claim bonus.';
        throw Exception(message);
      }
    } catch (e) {
      debugPrint('Error claiming bonus: $e');
      rethrow;
    }
  }
}
