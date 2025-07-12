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
        '$baseUrl/bank-account/$userId', // ← Tambahkan userId ke URL
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

  Future<BankAccount?> saveBankAccount(BuildContext context, String userId,
      String bankName, String accountNumber, String accountHolder) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }
      final response = await _dio.post(
        '$baseUrl/bank-account',
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
        // Perubahan di sini
        return BankAccount.fromJson(response.data); // Dan di sini
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('Error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        debugPrint('Error: ${e.message}');
      }
      return null;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return null;
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
        '$baseUrl/bank-account/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('Error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        debugPrint('Error: ${e.message}');
      }
      return false;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return false;
    }
  }
}
