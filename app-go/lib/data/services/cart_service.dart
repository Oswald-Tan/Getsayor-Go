import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:getsayor/presentation/providers/cart_provider.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:provider/provider.dart';
import 'package:getsayor/data/model/cart_item.dart';

class CartService {
  final Dio _dio = Dio();

  Future<void> addToCart(
    BuildContext context,
    String userId,
    String productItemId,
    int quantity,
  ) async {
    try {
      // Ambil ID pengguna dan token dari UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Konversi userId menjadi int
      final int userIdInt = int.tryParse(userId) ?? 0;
      if (userIdInt == 0) {
        throw Exception('Invalid user ID');
      }

      print('URL: $baseUrl/cart-app');
      print('Token: $token');
      print('Payload: ${{
        'userId': userIdInt,
        'productItemId': int.parse(productItemId),
        'quantity': quantity
      }}');

      final response = await _dio
          .post(
        '$baseUrl/cart-app',
        data: {
          'userId': userIdInt,
          'productItemId': int.parse(productItemId),
          'quantity': quantity
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Menambahkan token ke header
          },
        ),
      )
          .catchError((error) {
        debugPrint('Full error details: ${error.toString()}');
        debugPrint('Response data: ${error.response?.data}');
        throw error;
      });

      // Periksa apakah status code berhasil (200 OK atau 201 Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Pesanan berhasil: ${response.data}');

        // Perbarui cartItemCount dari server setelah menambahkan produk
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        int updatedCount =
            await getCartItemCount(context); // Ambil nilai terbaru dari server
        cartProvider
            .setCartItemCount(updatedCount); // Perbarui state di CartProvider
      } else {
        final errorMsg =
            response.data['message'] ?? "Gagal menambahkan ke keranjang";
        throw errorMsg;
      }
    } catch (e) {
      debugPrint('Error: $e');
      throw "Terjadi kesalahan saat menambahkan ke keranjang";
    }
  }

  Future<List<CartItem>> getCartItems(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.get(
        '$baseUrl/cart-app/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Tangani kondisi keranjang kosong
        if (response.data['cart'] == null ||
            (response.data['cart'] as List).isEmpty) {
          debugPrint('Keranjang kosong untuk user $userId');
          return []; // Mengembalikan array kosong
        }

        List<CartItem> cartItems = [];

        for (var item in (response.data['cart'] as List)) {
          try {
            cartItems.add(CartItem.fromJson(item));
          } catch (e, stackTrace) {
            debugPrint('Error parsing cart item: $e');
            debugPrint('StackTrace: $stackTrace');
            // Lewati item yang error
          }
        }

        return cartItems;
      } else {
        throw Exception(
            'Gagal memuat keranjang (status: ${response.statusCode})');
      }
    } catch (e, stackTrace) {
      // Log error untuk debug
      debugPrint('Error in getCartItems: $e');
      debugPrint('StackTrace: $stackTrace');

      // Tangani error selain autentikasi dengan array kosong
      if (e.toString().contains('User not authenticated')) {
        rethrow; // Lempar ulang error autentikasi
      }

      return []; // Mengembalikan array kosong jika error lain
    }
  }

  // Memperbarui jumlah berat di keranjang
  Future<void> updateCartItem(
      BuildContext context, int userId, int productItemId, int quantity) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        throw 'User not authenticated'; // Lempar pesan error sebagai string, bukan Exception
      }

      final response = await _dio.post(
        '$baseUrl/cart-app/update-berat',
        data: {
          'userId': userId,
          'productItemId': productItemId,
          'quantity': quantity,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.data}');

      if (response.statusCode == 200) {
        debugPrint('Keranjang berhasil diperbarui');
      } else {
        // Tangkap pesan error dari backend jika status code bukan 200
        final errorMessage = response.data['message'] ??
            'Failed to update cart item on the server';
        throw errorMessage; // Lempar pesan error sebagai string, bukan Exception
      }
    } on DioException catch (e) {
      // Tangkap pesan error dari backend jika terjadi DioException
      if (e.response != null && e.response!.data != null) {
        final errorMessage = e.response!.data['message'] ??
            'Terjadi kesalahan saat memperbarui keranjang';
        throw errorMessage; // Lempar pesan error sebagai string, bukan Exception
      } else {
        throw 'Terjadi kesalahan saat menghubungi server'; // Lempar pesan error sebagai string
      }
    } catch (e) {
      debugPrint('Error: $e');
      throw 'Terjadi kesalahan tidak terduga'; // Lempar pesan error sebagai string
    }
  }

  Future<int> getCartItemCount(context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.get(
        '$baseUrl/cart-app/item-count/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        int itemCount = response.data['itemCount'];
        return itemCount;
      } else {
        throw Exception(
            'Gagal memuat jumlah item keranjang (status: ${response.statusCode})');
      }
    } catch (e, stackTrace) {
      debugPrint('Error in getCartItemCount: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Failed to get cart item count');
    }
  }

  // Hapus item di keranjang berdasarkan cartId
  Future<void> deleteCartItem(
      BuildContext context, int userId, String cartId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
            data: {'message': 'User not authenticated'},
          ),
        );
      }

      final response = await _dio.delete(
        '$baseUrl/cart-app/$cartId',
        data: {'userId': userId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('Cart item deleted successfully: ${response.data}');

        // Update cart item count
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        int updatedCount = await getCartItemCount(context);
        cartProvider.setCartItemCount(updatedCount);
      } else {
        throw DioException(
          response: response,
          requestOptions: response.requestOptions,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow; // Rethrow for UI layer to handle
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.unknown,
        error: e,
      );
    }
  }
}
