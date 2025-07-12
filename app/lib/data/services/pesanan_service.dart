import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:getsayor/data/model/pesanan_model.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:provider/provider.dart';

class PesananService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<PesananModel>> getPesananByUser(
      BuildContext context, int userId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.get(
        '$baseUrl/pesanan-app/user/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return (response.data['data'] as List)
          .map((pesanan) => PesananModel.fromJson(pesanan))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Timeout: Silakan coba lagi');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Koneksi jaringan bermasalah');
      }
      debugPrint('Error: ${e.message}');
      throw Exception('Gagal mengambil pesanan: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga');
    }
  }

  Future<List<PesananModel>> getPesananByUserDelivered(
      BuildContext context, int userId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.get(
        '$baseUrl/pesanan-app/user-delivered/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return (response.data['data'] as List)
          .map((pesanan) => PesananModel.fromJson(pesanan))
          .toList();
    } on DioException catch (e) {
      debugPrint('Error: ${e.message}');
      throw Exception('Gagal mengambil pesanan: ${e.message}');
    }
  }

  Future<bool> bayarDenganCOD(
    context,
    int totalBayar,
    int ongkir,
    int totalBayarSemua,
    String invoiceNumber,
    List<Map<String, dynamic>> items,
    String idempotencyKey,
  ) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw 'User not authenticated';
      }

      final response = await _dio
          .post(
            '$baseUrl/pesanan-app/cod',
            data: {
              'userId': userId,
              'metodePembayaran': 'COD',
              'hargaRp': totalBayar,
              'ongkir': ongkir,
              'totalBayar': totalBayarSemua,
              'invoiceNumber': invoiceNumber,
              'items': items,
              'idempotencyKey': idempotencyKey,
            },
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw DioException(
              requestOptions: RequestOptions(path: '/'),
              error: 'Timeout setelah 10 detik',
              type: DioExceptionType.connectionTimeout,
            ),
          );

      // Terima semua status success 2xx
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return true;
      }

      throw _parseError(response);
    } on DioException catch (e) {
      debugPrint('DioError: ${e.toString()}');

      // Handle timeout khusus
      if (e.type == DioExceptionType.connectionTimeout) {
        final isOrderCreated = await _checkOrderExists(idempotencyKey);
        if (isOrderCreated) return true;
        throw 'Timeout tetapi order tidak terdeteksi. Silakan coba lagi.';
      }

      // Handle error response dari server
      if (e.response != null) {
        if (e.response!.statusCode == 409) {
          return true; // Idempotency conflict - order sudah ada
        }
        throw _parseError(e.response!);
      }

      throw 'Gagal terhubung ke server: ${e.message}';
    } catch (e) {
      debugPrint('General error: $e');
      rethrow;
    }
  }

  String _parseError(Response response) {
    try {
      return response.data['message'] ??
          response.data['error'] ??
          'Terjadi kesalahan (${response.statusCode})';
    } catch (_) {
      return 'Terjadi kesalahan tidak terduga (${response.statusCode})';
    }
  }

  Future<bool> _checkOrderExists(String idempotencyKey) async {
    try {
      final response = await _dio.get(
        '$baseUrl/pesanan-app/check',
        queryParameters: {'idempotencyKey': idempotencyKey},
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      return response.statusCode == 200 && response.data != null;
    } on DioException catch (e) {
      debugPrint('Check order error: ${e.message}');
      return false;
    }
  }

  Future<bool> bayarDenganCODCart(
    context,
    String id,
    // String nama,
    int hargaRp,
    int ongkir,
    int totalBayar,
    String invoiceNumber,
    List<Map<String, dynamic>> items,
    String idempotencyKey,
  ) async {
    try {
      // Ambil ID pengguna dan token dari UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId; // Ambil user ID

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      // Kirim data top-up melalui POST request
      final response = await _dio
          .post(
            '$baseUrl/pesanan-app/cod-cart',
            data: {
              'userId': userId,
              'id': id,
              // 'nama': nama,
              'metodePembayaran': 'COD',
              'hargaRp': hargaRp,
              'ongkir': ongkir,
              'totalBayar': totalBayar,
              'status': 'pending',
              'invoiceNumber': invoiceNumber,
              'items': items,
              'idempotencyKey': idempotencyKey,
            },
            options: Options(
              headers: {
                'Authorization': 'Bearer $token', // Menambahkan token ke header
              },
            ),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw DioException(
              requestOptions: RequestOptions(path: '/'),
              error: 'Timeout setelah 10 detik',
              type: DioExceptionType.connectionTimeout,
            ),
          );
      // Terima semua status success 2xx
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return true;
      }

      throw _parseError(response);
    } on DioException catch (e) {
      debugPrint('DioError: ${e.toString()}');

      // Handle timeout khusus
      if (e.type == DioExceptionType.connectionTimeout) {
        final isOrderCreated = await _checkOrderExists(idempotencyKey);
        if (isOrderCreated) return true;
        throw 'Timeout tetapi order tidak terdeteksi. Silakan coba lagi.';
      }

      // Handle error response dari server
      if (e.response != null) {
        if (e.response!.statusCode == 409) {
          return true; // Idempotency conflict - order sudah ada
        }
        throw _parseError(e.response!);
      }

      throw 'Gagal terhubung ke server: ${e.message}';
    } catch (e) {
      debugPrint('General error: $e');
      rethrow;
    }
  }

  Future<bool> bayarDenganPoin(
    context,
    int totalBayar,
    int ongkir,
    int totalBayarSemua,
    String invoiceNumber,
    List<Map<String, dynamic>> items,
    String idempotencyKey,
  ) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw 'User not authenticated';
      }

      final response = await _dio
          .post(
            '$baseUrl/pesanan-app/poin',
            data: {
              'userId': userId,
              'metodePembayaran': 'Poin',
              'hargaPoin': totalBayar,
              'ongkir': ongkir,
              'totalBayar': totalBayarSemua,
              'invoiceNumber': invoiceNumber,
              'items': items,
              'idempotencyKey': idempotencyKey,
            },
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw DioException(
              requestOptions: RequestOptions(path: '/'),
              error: 'Timeout setelah 10 detik',
              type: DioExceptionType.connectionTimeout,
            ),
          );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return true;
      }

      throw _parseError(response);
    } on DioException catch (e) {
      debugPrint('DioError: ${e.toString()}');

      // Handle timeout khusus
      if (e.type == DioExceptionType.connectionTimeout) {
        final isOrderCreated = await _checkOrderExists(idempotencyKey);
        if (isOrderCreated) return true;
        throw 'Timeout tetapi order tidak terdeteksi. Silakan coba lagi.';
      }

      // Handle error response dari server
      if (e.response != null) {
        if (e.response!.statusCode == 409) {
          return true; // Idempotency conflict - order sudah ada
        }

        final errorData = e.response!.data;
        if (errorData is Map && errorData.containsKey('message')) {
          final message = errorData['message'] as String;
          if (message.contains("Poin Anda hanya")) {
            throw message;
          }
        }

        throw _parseError(e.response!);
      }

      throw 'Gagal terhubung ke server: ${e.message}';
    } catch (e) {
      debugPrint('General error: $e');
      rethrow;
    }
  }

  Future<bool> bayarDenganPoinCart(
    context,
    String id,
    int hargaPoin,
    int ongkir,
    int totalBayar,
    String invoiceNumber,
    List<Map<String, dynamic>> items,
    String idempotencyKey,
  ) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio
          .post(
            '$baseUrl/pesanan-app/poin-cart',
            data: {
              'userId': userId,
              'id': id,
              'metodePembayaran': 'Poin',
              'hargaPoin': hargaPoin,
              'ongkir': ongkir,
              'totalBayar': totalBayar,
              'status': 'pending',
              'invoiceNumber': invoiceNumber,
              'items': items,
              'idempotencyKey': idempotencyKey,
            },
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw DioException(
              requestOptions: RequestOptions(path: '/'),
              error: 'Timeout setelah 10 detik',
              type: DioExceptionType.connectionTimeout,
            ),
          );

      // Terima semua status success 2xx
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return true;
      }

      throw _parseError(response);
    } on DioException catch (e) {
      debugPrint('DioError: ${e.toString()}');

      // Handle timeout khusus
      if (e.type == DioExceptionType.connectionTimeout) {
        final isOrderCreated = await _checkOrderExists(idempotencyKey);
        if (isOrderCreated) return true;
        throw 'Timeout tetapi order tidak terdeteksi. Silakan coba lagi.';
      }

      // Handle error response dari server
      if (e.response != null) {
        if (e.response!.statusCode == 409) {
          return true; // Idempotency conflict - order sudah ada
        }

        final errorData = e.response!.data;
        if (errorData is Map && errorData.containsKey('message')) {
          final message = errorData['message'] as String;
          if (message.contains("Poin Anda hanya")) {
            throw message;
          }
        }

        throw _parseError(e.response!);
      }

      throw 'Gagal terhubung ke server: ${e.message}';
    } catch (e) {
      debugPrint('General error: $e');
      rethrow;
    }
  }
}
