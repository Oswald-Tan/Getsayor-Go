import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/data/model/poin_model.dart';

class PoinService {
  final Dio _dio = Dio();

  // Endpoint API untuk mendapatkan data poin
  Future<List<Poin>> fetchPoin(BuildContext context) async {
    try {
      // Ambil token dari UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Kirim request dengan token di header Authorization
      final response = await _dio.get(
        '$baseUrl/poin-app',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Menambahkan token ke header
          },
        ),
      );

      if (response.statusCode == 200) {
        // Mengambil data poin dari response
        List<Poin> poinList =
            (response.data as List).map((json) => Poin.fromJson(json)).toList();

        return poinList;
      } else {
        throw Exception('Failed to load poin');
      }
    } catch (e) {
      throw Exception('Error fetching poin: $e');
    }
  }

  // Fungsi untuk melakukan top-up data ke server
  Future<void> postTopUpData(BuildContext context, int points, int price,
      DateTime date, String bankName) async {
    try {
      // Ambil ID pengguna dan token dari UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId; // Ambil user ID

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      // Kirim data top-up melalui POST request
      final response = await _dio.post(
        '$baseUrl/topup-app', // Gantilah dengan endpoint yang sesuai
        data: {
          'userId': userId, // Mengirim ID pengguna
          'points': points,
          'price': price,
          'date': date.toIso8601String(),
          'bankName': bankName,
          'status': 'pending',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Menambahkan token ke header
          },
        ),
      );

      if (response.statusCode == 201) {
        debugPrint('Top-Up berhasil: ${response.data}');
        // Menangani keberhasilan
      } else {
        debugPrint('Failed with status: ${response.statusCode}');
        throw Exception('Failed to top-up');
      }
    } catch (e) {
      throw Exception('Error during top-up: $e');
    }
  }
}
