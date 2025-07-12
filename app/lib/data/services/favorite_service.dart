import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/data/model/produk_model.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';

class FavoriteService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<bool> toggleFavorite(BuildContext context, int productId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        throw "Pengguna belum login";
      }

      final response = await _dio.post(
        '$baseUrl/favorites/toggle',
        data: {'productId': productId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data['isFavorite'] as bool;
      } else {
        throw "Terjadi kesalahan server (${response.statusCode})";
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw "Error: ${e.response!.data['message'] ?? e.response!.statusMessage}";
      } else {
        throw "Koneksi jaringan bermasalah";
      }
    } catch (e) {
      throw "Terjadi kesalahan tak terduga";
    }
  }

  Future<List<Produk>> getFavorites(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.get(
        '$baseUrl/favorites',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        // Parse as List<dynamic> first
        final List<dynamic> data = response.data;

        // Convert each item to Produk with isFavorite=true
        List<Produk> produkList =
            data.map((json) => Produk.fromJson(json)).toList();

        return produkList;
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get favorites: $e');
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
