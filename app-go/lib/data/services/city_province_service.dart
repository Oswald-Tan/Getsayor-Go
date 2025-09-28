import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/data/model/city_province_model.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:provider/provider.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';

class ProvinceService {
  final Dio _dio = Dio();

  Future<List<Province>> fetchProvinces(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;

      // Pastikan token dan userId ada
      if (token == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.get(
        '$baseUrl/provinces-cities',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List provinces = response.data['data'];

        return provinces
            .map((province) => Province.fromJson(province))
            .toList();
      } else {
        throw Exception('Failed to load provinces');
      }
    } catch (error) {
      throw Exception('Error fetching provinces: $error');
    }
  }
}
