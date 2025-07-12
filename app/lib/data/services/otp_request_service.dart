import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/data/model/otp_request_model.dart';
import 'package:getsayor/core/api/config.dart';

class OTPRequestService {
  late final Dio _dio;

  OTPRequestService() {
    final options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    );
    _dio = Dio(options);
  }

  Future<OtpResponse> requestOtp(BuildContext context, String email) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/request-reset-otp',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return OtpResponse.fromJson(response.data);
      } else {
        throw DioException(
          response: response,
          requestOptions: response.requestOptions,
        );
      }
    } on DioException {
      rethrow;
    } catch (_) {
      throw Exception("Terjadi kesalahan internal");
    }
  }

  // Verify OTP
  Future<OtpResponse> verifyOtp(
      BuildContext context, String email, String otp) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/verify-reset-otp',
        data: {'email': email, 'otp': otp},
      );

      if (response.statusCode == 200) {
        return OtpResponse.fromJson(response.data);
      } else {
        throw DioException(
          response: response,
          requestOptions: response.requestOptions,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow;
    } catch (_) {
      throw Exception("Terjadi kesalahan internal");
    }
  }

  // Reset Password
  Future<OtpResponse> resetPassword(BuildContext context, String email,
      String newPassword, String confirmPassword) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/reset-password',
        data: {
          'email': email,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword
        },
      );

      if (response.statusCode == 200) {
        return OtpResponse.fromJson(response.data);
      } else {
        throw DioException(
          response: response,
          requestOptions: response.requestOptions,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception("Terjadi kesalahan internal");
    }
  }

  Future<String> getResetOtpExpiry(BuildContext context, String email) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/get-reset-otp-expiry',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return response.data['expiryTime'] as String;
      } else {
        throw DioException(
          response: response,
          requestOptions: response.requestOptions,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception("Terjadi kesalahan internal");
    }
  }
}
