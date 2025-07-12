import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/data/model/total_bonus_model.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:provider/provider.dart';

class TotalBonusService {
  final Dio _dio = Dio();

  // Fungsi untuk mengambil total bonus dari API
  Future<TotalBonus> getTotalBonus(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      // Cek apakah token dan userId tersedia
      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.get(
        '$baseUrl/afiliasi-bonus-app/total/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Cek status code dari response
      if (response.statusCode == 200) {
        final data = response.data;
        final totalBonus = data['totalBonus'] ?? 0;
        return TotalBonus(
          totalBonus: totalBonus,
          message: data['message'] ?? 'No message provided',
        );
      } else {
        throw Exception('Failed to load total bonus: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching total bonus: $e');
      throw Exception('Error: $e');
    }
  }

  Future<double> getPendingBonus(BuildContext context) async {
    try {
      // Ambil token dari UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      // Kirim request dengan token di header Authorization
      final response = await _dio.get(
        '$baseUrl/afiliasi-bonus-app/pending/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Menambahkan token ke header
          },
        ),
      );

      // Cek apakah response status code 200 OK
      if (response.statusCode == 200) {
        // Ambil nilai total bonus dari response
        final data = response.data;
        double totalBonus = data['totalBonus'].toDouble();

        return totalBonus;
      } else {
        throw Exception('Failed to load total bonus');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}
