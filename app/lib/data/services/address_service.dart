import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/data/model/address_model.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:provider/provider.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddressService {
  final Dio _dio = Dio();

  // Fungsi untuk mendapatkan daftar alamat pengguna
  Future<List<Address>> getUserAddresses(
      BuildContext context, int? userId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      // Pastikan token dan userId tidak null
      if (token == null || userId == null) {
        throw Exception('User not authenticated or userId is null');
      }

      final response = await _dio.get(
        '$baseUrl/addresses/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Cek apakah response status code adalah 200
      if (response.statusCode == 200) {
        final responseData = response.data;
        debugPrint("Response data: $responseData");

        // Pastikan responseData mengandung key 'data' yang valid
        if (responseData != null && responseData.containsKey('data')) {
          // Mengonversi data menjadi List<Address>
          List<Address> addresses = (responseData['data'] as List)
              .map((addressData) => Address.fromJson(addressData))
              .toList();
          return addresses;
        } else {
          // Jika data tidak valid
          throw Exception('Invalid response format: Missing "data" key');
        }
      } else {
        // Jika status code tidak 200
        throw Exception(
            'Failed to load addresses, status code: ${response.statusCode}');
      }
    } catch (error) {
      // Menangani error dengan lebih rinci
      debugPrint("Error fetching user addresses: $error");
      rethrow; // Meneruskan error untuk ditangani di tempat lain
    }
  }

  //dapatkan alamat berdasarkann Id
  Future<Address?> getAddressById(
      {required context, required int addressId}) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.get(
        '$baseUrl/addresses/get-address-id/$addressId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final address = Address.fromJson(response.data['data']);
        return address;
      } else {
        String errorMessage = 'Failed to retrieve address';
        if (response.data != null && response.data['message'] != null) {
          errorMessage = response.data['message'];
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (error) {
      debugPrint("Error retrieving address: $error");
      if (error is DioException) {
        debugPrint("DioException Details:");
        debugPrint("Type: ${error.type}");
        debugPrint("Message: ${error.message}");
        debugPrint("Response: ${error.response?.data}");
        debugPrint("Status Code: ${error.response?.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error retrieving address")),
        );
      }
    }
    return null;
  }

  // Fungsi untuk mengedit alamat
  Future<Map<String, dynamic>> editAddress({
    required BuildContext context,
    required int id,
    required String recipientName,
    required String phoneNumber,
    required String addressLine1,
    required String city,
    required String state,
    required String postalCode,
    required bool isDefault,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.put(
        '$baseUrl/addresses/$id',
        data: {
          'user_id': userId,
          'recipient_name': recipientName,
          'phone_number': phoneNumber,
          'address_line_1': addressLine1,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'isDefault': isDefault,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Address updated successfully!");
        return response.data; // Mengembalikan data dari server
      } else {
        debugPrint(
            "Failed to update address. Status Code: ${response.statusCode}");
        throw Exception('Failed to update address');
      }
    } catch (error) {
      debugPrint("Error updating address: $error");
      rethrow; // Melempar kembali error ke pemanggil
    }
  }

  // Fungsi untuk mendapatkan alamat default pengguna
  Future<Address?> getDefaultAddress(context, int? userId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      debugPrint("Token: $token");
      debugPrint("User ID: $userId");

      if (token == null || userId == null) {
        debugPrint("User not authenticated.");
        throw Exception('User not authenticated.');
      }

      final response = await _dio.get(
        '$baseUrl/addresses/default/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint("Response data default address: $data");

        if (data != null && data['defaultAddress'] != null) {
          // Memanggil Address.fromJson dengan data['defaultAddress']
          Address address = Address.fromJson(data['defaultAddress']);

          // Pemetaan shippingRate terpisah dari defaultAddress
          if (data['shippingRate'] != null) {
            address = address.copyWith(
                shippingRate: ShippingRate.fromJson(data['shippingRate']));
          }

          return address;
        } else {
          debugPrint("Default address not found for user $userId.");
          return null;
        }
      } else {
        debugPrint(
            "Failed to fetch default address. Status code: ${response.statusCode}");
        throw Exception('Failed to fetch default address.');
      }
    } catch (error) {
      debugPrint("Error while fetching default address: $error");
      return null;
    }
  }

  // Fungsi untuk menambahkan alamat
  Future<void> addAddress({
    required context,
    required int? userId,
    required String recipientName,
    required String phoneNumber,
    required String addressLine1,
    required String city,
    required String state,
    required String postalCode,
    required bool isDefault,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      // Pastikan token tidak null
      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Validasi input
      if (recipientName.isEmpty ||
          phoneNumber.isEmpty ||
          addressLine1.isEmpty ||
          city.isEmpty ||
          state.isEmpty ||
          postalCode.isEmpty) {
        throw Exception('All fields are required');
      }

      // Kirim permintaan POST ke server
      final response = await _dio.post(
        '$baseUrl/addresses',
        data: {
          'user_id': userId,
          'recipient_name': recipientName,
          'phone_number': phoneNumber,
          'address_line_1': addressLine1,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'isDefault': isDefault,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Periksa status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Address added successfully!");
        // Inform user with a success message

        Fluttertoast.showToast(
          toastLength: Toast.LENGTH_SHORT,
          msg: "Alamat berhasil ditambahkan",
          gravity: ToastGravity.TOP,
          backgroundColor: const Color(0xFF74B11A),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        debugPrint(
            "Failed to add address. Status Code: ${response.statusCode}");
        // Check if the response contains error messages
        String errorMessage = 'Failed to add address';
        if (response.data != null && response.data['message'] != null) {
          errorMessage = response.data['message'];
        }
        // Show error message in Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (error) {
      debugPrint("Error adding address: $error");

      // Jika ada DioException, log detailnya
      if (error is DioException) {
        debugPrint("DioException Details:");
        debugPrint("Type: ${error.type}");
        debugPrint("Message: ${error.message}");
        debugPrint("Response: ${error.response?.data}");
        debugPrint("Status Code: ${error.response?.statusCode}");

        // Handle error response and display the error message
        String errorMessage = 'Error adding address';
        if (error.response != null && error.response?.data != null) {
          errorMessage = error.response?.data['message'] ?? errorMessage;
        }

        // Display the error message in the snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  // Fungsi untuk menghapus alamat
  Future<bool> deleteAddress(BuildContext context, int id) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      // Pastikan user terautentikasi
      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.delete(
        '$baseUrl/addresses/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) {
            return status != null &&
                status < 500; // Status 400 tidak dianggap error
          },
        ),
      );

      // Jika berhasil dihapus
      if (response.statusCode == 200) {
        debugPrint('Address successfully deleted');
        return true; // Penghapusan berhasil
      }

      // Jika gagal karena validasi dari backend
      else if (response.statusCode == 400) {
        final message = response.data['message'];
        debugPrint("Error Message from Backend: $message");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        return false; // Penghapusan gagal
      }

      // Jika ada kode status lain yang tidak terduga
      else {
        debugPrint("Unexpected status code: ${response.statusCode}");
        throw Exception('Failed to delete address');
      }
    } catch (error) {
      // Tangani error dari Dio atau lainnya
      if (error is DioException) {
        debugPrint("DioException: ${error.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.message}')),
        );
      } else {
        debugPrint("Unknown error: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting address: $error')),
        );
      }
      return false; // Jika ada error, kembalikan false
    }
  }

  // Fungsi untuk mendapatkan daftar kota yang didukung
  Future<List<String>> getCities(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      // Pastikan token ada
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.get(
        '$baseUrl/supported-area-app/cities',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Mengonversi data ke dalam list String
        List<String> cities = List<String>.from(response.data['data']);
        return cities;
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (error) {
      debugPrint("Error fetching cities: $error");
      throw Exception('Failed to load cities');
    }
  }

  Future<List<String>> getStates(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      // Pastikan token ada
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await _dio.get(
        '$baseUrl/supported-area-app/states',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Mengonversi data ke dalam list String
        List<String> states = List<String>.from(response.data['data']);
        return states;
      } else {
        throw Exception('Failed to load states');
      }
    } catch (error) {
      debugPrint("Error fetching states: $error");
      throw Exception('Failed to load states');
    }
  }
}
