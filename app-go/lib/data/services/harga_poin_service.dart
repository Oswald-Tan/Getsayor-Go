import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/data/model/harga_poin_model.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';

class HargaPoinService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<HargaPoinModel> getHargaPoin(BuildContext context) async {
    try {
      // Ambil token dari UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio
          .get(
        '$baseUrl/settings-app/harga-poin',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Menambahkan token ke header
          },
        ),
      )
          .timeout(
        const Duration(seconds: 10), // Timeout 10 detik
        onTimeout: () {
          // Jika timeout terjadi, return custom response atau exception
          throw 'Connection timeout, please try again later.';
        },
      );

      if (response.statusCode == 200) {
        return HargaPoinModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load harga poin');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
