import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/data/model/produk_model.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';

class FavoriteService {
  final Dio _dio = Dio();

  Future<bool> toggleFavorite(BuildContext context, int productId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) throw "User not authenticated";

      final response = await _dio
          .post(
            '$baseUrl/favorites/toggle',
            data: {'productId': productId},
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        return response.data['isFavorite'] as bool;
      } else {
        throw "Server responded with status ${response.statusCode}";
      }
    } on DioException catch (e) {
      // Lempar ulang dengan pesan yang lebih spesifik
      if (e.response != null) {
        final message = e.response!.data['message'] ?? e.message;
        throw "Error: $message (${e.response!.statusCode})";
      } else {
        throw "Koneksi jaringan bermasalah: ${e.message}";
      }
    } catch (e) {
      throw "Terjadi kesalahan: $e";
    }
  }

  Future<List<Produk>> getFavorites(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) throw "User not authenticated";

      final response = await _dio.get(
        '$baseUrl/favorites',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return (response.data as List)
          .map((json) => Produk.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? "Failed to load favorites";
    }
  }

  Future<bool> checkFavorite(BuildContext context, int productId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        return false;
      }

      final response = await _dio.get(
        '$baseUrl/favorites/$productId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Access the boolean value directly
      return response.data['isFavorite'] as bool;
    } catch (e) {
      // Return false on any error
      return false;
    }
  }
}
