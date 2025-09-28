import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:provider/provider.dart';

class UserService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> updateUser(BuildContext context, int userId,
      String? fullname, String? phoneNumber, String? email) async {
    try {
      // Get the token from UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      if (token == null) {
        throw Exception('User not authenticated.');
      }

      // Prepare the data for the update request
      final data = <String, dynamic>{};

      if (fullname != null && fullname.isNotEmpty) {
        data['fullname'] = fullname;
      }

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        data['phone_number'] = phoneNumber;
      }

      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }

      // Send the PATCH request
      final response = await _dio.put(
        '$baseUrl/auth-app/$userId',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'User updated successfully',
        };
      } else {
        return {
          'status': false,
          'message': 'Failed to update user',
        };
      }
    } catch (e) {
      // Handle errors
      debugPrint('Error: $e');
      return {
        'status': false,
        'message': 'An error occurred while updating user',
      };
    }
  }
}
