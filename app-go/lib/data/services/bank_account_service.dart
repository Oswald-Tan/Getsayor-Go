import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/data/model/bank_account_model.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';

class BankAccountService {
  final Dio _dio = Dio();

  Future<BankAccount?> getBankAccount(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.get(
        '$baseUrl/bank-accounts/$userId', // ← Tambahkan userId ke URL
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return BankAccount.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('Error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        debugPrint('Error: ${e.message}');
        throw Exception('Error: ${e.message}');
      }
      return null;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return null;
    }
  }

  Future<bool> hasBankAccount(BuildContext context) async {
    try {
      final account = await getBankAccount(context);
      return account != null &&
          account.bankName.isNotEmpty &&
          account.accountNumber.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  // Di BankAccountService, metode saveBankAccount:

  Future<BankAccount?> saveBankAccount(BuildContext context, int userId,
      String bankName, String accountNumber, String accountHolder) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }
      final response = await _dio.post(
        '$baseUrl/bank-accounts',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          'userId': userId,
          'bankName': bankName,
          'accountNumber': accountNumber,
          'accountHolder': accountHolder,
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        // Handle kemungkinan null
        if (response.data is Map<String, dynamic>) {
          return BankAccount.fromJson(response.data as Map<String, dynamic>);
        } else {
          debugPrint('Invalid response format');
          return null;
        }
      }
      return null;
    } on DioException catch (e) {
      String errorMessage = "Terjadi kesalahan";

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = "Waktu koneksi habis, silakan coba lagi";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            "Tidak dapat terhubung ke server, periksa koneksi internet Anda";
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;

        if (statusCode == 400) {
          errorMessage = "Data rekening tidak valid";
        } else if (statusCode == 401) {
          errorMessage = "Sesi habis, silakan login kembali";
        } else if (statusCode == 500) {
          errorMessage = "Server mengalami masalah, silakan coba nanti";
        } else {
          errorMessage = "Terjadi kesalahan server ($statusCode)";
        }
      } else {
        errorMessage = "Terjadi kesalahan tak terduga";
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Terjadi kesalahan tak terduga");
    }
  }

  Future<bool> deleteBankAccount(BuildContext context, String userId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.delete(
        '$baseUrl/bank-accounts/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      String errorMessage = "Gagal menghapus rekening";

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        errorMessage = "Tidak dapat terhubung ke server";
      } else if (e.response != null) {
        if (e.response!.statusCode == 404) {
          errorMessage = "Rekening tidak ditemukan";
        } else if (e.response!.statusCode == 401) {
          errorMessage = "Sesi habis, silakan login kembali";
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Gagal menghapus rekening");
    }
  }
}
