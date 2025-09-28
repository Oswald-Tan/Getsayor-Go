import 'package:getsayor/data/services/favorite_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/data/model/produk_model.dart';
import 'package:provider/provider.dart';

class ProdukService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  final FavoriteService _favoriteService = FavoriteService();

  Future<List<Produk>> fetchProduk2(BuildContext context) async {
    try {
      // Ambil token dari UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Kirim request dengan token di header Authorization
      final response = await _dio
          .get(
        '$baseUrl/products/app',
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

      // print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Mengambil data poin dari response
        List<Produk> produkList = (response.data as List)
            .map((json) => Produk.fromJson(json))
            .toList();

        await _loadFavoriteStatus(context, produkList);

        return produkList;
      } else {
        throw Exception('Failed to load produk');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<List<Produk>> fetchProduk(
    BuildContext context, {
    required int page,
    required int perPage,
    String? category,
  }) async {
    try {
      // Ambil token dari UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Kirim request dengan token di header Authorization
      final response = await _dio.get(
        '$baseUrl/products/app/app',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Menambahkan token ke header
          },
        ),
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'kategori': category,
        },
      ).timeout(
        const Duration(seconds: 10), // Timeout 10 detik
        onTimeout: () {
          // Jika timeout terjadi, return custom response atau exception
          throw 'Connection timeout, please try again later.';
        },
      );

      if (response.statusCode == 200) {
        // Mengambil data poin dari response
        List<Produk> produkList = (response.data['data']['data'] as List)
            .map((json) => Produk.fromJson(json))
            .toList();

        await _loadFavoriteStatus(context, produkList);

        return produkList;
      } else {
        throw Exception('Failed to load produk');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<List<Produk>> searchProduk(
    BuildContext context, {
    required String query,
    required String category,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      final response = await _dio.get(
        '$baseUrl/products/app/search',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: {
          'query': query,
          'kategori': category == 'All' ? null : category,
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['data'] as List;
        return data.map((json) => Produk.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Search error: $e");
      return [];
    }
  }

  Future<void> _loadFavoriteStatus(
      BuildContext context, List<Produk> products) async {
    for (var product in products) {
      try {
        final isFavorite =
            await _favoriteService.checkFavorite(context, product.id);
        product.isFavorite = isFavorite;
      } catch (e) {
        product.isFavorite = false;
      }
    }
  }
}
