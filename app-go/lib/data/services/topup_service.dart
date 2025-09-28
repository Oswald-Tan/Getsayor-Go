import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:provider/provider.dart';
import 'package:getsayor/data/model/top_up_poin_model.dart';

class TopUpException implements Exception {
  final String message;
  final bool retryable;

  TopUpException(this.message, {this.retryable = true});

  @override
  String toString() => message;
}

class TopUpPoinService {
  final Dio _dio;

  TopUpPoinService() : _dio = Dio() {
    _dio.options = BaseOptions(
      // Replace with your actual base URL
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    );

    // Add interceptors for better logging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));
  }

  // Fungsi untuk melakukan top-up data ke server
  Future<void> postTopUpData(
    String token,
    int userId,
    int points,
    int price,
    DateTime date,
    String paymentMethod,
    String purchaseId,
    String invoiceNumber,
  ) async {
    try {
      if (token.isEmpty || userId == 0) {
        throw TopUpException('User not authenticated', retryable: false);
      }

      final response = await _dio
          .post(
            '$baseUrl/topup-app',
            data: {
              'userId': userId,
              'points': points,
              'price': price,
              'date': date.toIso8601String(),
              'paymentMethod': paymentMethod,
              'purchaseId': purchaseId,
              'status': 'success',
              'invoiceNumber': invoiceNumber,
            },
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              validateStatus: (status) => status != null && status < 500,
            ),
          )
          .timeout(const Duration(seconds: 30));

      // Handle response based on status code
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        debugPrint('Top-Up successful');
        return;
      } else {
        // Handle specific error status codes
        final errorData = response.data ?? {};
        final errorMessage = errorData['message'] ?? 'Unknown error';

        switch (response.statusCode) {
          case 400:
            throw TopUpException('Invalid request: $errorMessage',
                retryable: false);
          case 401:
            throw TopUpException('Session expired. Please login again',
                retryable: false);
          case 409:
            throw TopUpException('Conflict: $errorMessage', retryable: false);
          default:
            throw TopUpException('Server error: $errorMessage',
                retryable: true);
        }
      }
    } on SocketException catch (_) {
      throw TopUpException('No internet connection', retryable: true);
    } on TimeoutException catch (_) {
      throw TopUpException('Request timed out. Please try again',
          retryable: true);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw TopUpException('Connection timeout', retryable: true);
      } else if (e.type == DioExceptionType.badResponse) {
        // Handle server errors (500+)
        if (e.response?.statusCode == 500) {
          throw TopUpException('Internal server error', retryable: true);
        } else {
          final errorMessage = e.response?.data['message'] ?? 'Server error';
          throw TopUpException(errorMessage, retryable: true);
        }
      } else {
        throw TopUpException('Network error: ${e.message}', retryable: true);
      }
    } catch (e) {
      throw TopUpException('Unexpected error: $e', retryable: false);
    }
  }

  // Fungsi untuk mengambil data top-up dari server
  Future<List<TopUpPoin>> fetchTopUpPoin(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio
          .get(
        '$baseUrl/topup-app/user',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          // Terima status 404 sebagai respons valid (tidak throw exception)
          validateStatus: (status) => status! < 500,
        ),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw 'Connection timeout, please try again later.';
        },
      );

      // Handle status code 404: kembalikan list kosong
      if (response.statusCode == 404) {
        return [];
      }

      // Handle status code 200
      if (response.statusCode == 200) {
        // Handle pesan khusus dari backend
        if (response.data is Map && response.data['message'] != null) {
          final message = response.data['message'] as String;

          if (message == "Belum ada data" || message == "Belum ada Top Up") {
            return []; // Kembalikan list kosong
          } else {
            throw Exception(message); // Lempar pesan error dari backend
          }
        } else if (response.data is List) {
          List<dynamic> data = response.data;
          return data.map((json) => TopUpPoin.fromJson(json)).toList();
        } else {
          throw Exception('Format data tidak valid');
        }
      }

      // Jika status code selain 200 dan 404, coba ambil pesan error
      final errorMessage = response.data?['message'] ??
          'Failed to fetch top-up data. Status code: ${response.statusCode}';
      throw Exception(errorMessage);
    } catch (error) {
      debugPrint("Error: $error");

      // Berikan pesan error yang lebih spesifik
      if (error is DioException) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          throw 'Koneksi timeout. Periksa jaringan internet Anda';
        } else if (error.response?.statusCode == 500) {
          throw 'Server sedang mengalami masalah';
        } else {
          throw 'Gagal terhubung ke server';
        }
      }
      throw 'Terjadi kesalahan: $error';
    }
  }

  Future<void> cancelTopUp(String topUpId, BuildContext context) async {
    try {
      // Ambil token dari UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.post(
        '$baseUrl/topup-app/cancel/$topUpId',
        data: {
          'status': 'cancelled',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('Status updated successfully');
        // Handle success, misalnya tampilkan pesan atau update UI
      } else {
        debugPrint('Failed to update status');
        throw Exception('Failed to cancel top-up');
      }
    } catch (e) {
      debugPrint('Error during cancellation: $e');
    }
  }
}
