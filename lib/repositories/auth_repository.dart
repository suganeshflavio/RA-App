import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/auth_models.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<LoginData> login({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    try {
      final response = await _client.post(
        '/api/auth/login',
        data: {'email': email, 'password': password, 'deviceId': deviceId},
      );
      final body = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      if (!body.success) throw ApiException(body.message);
      return body.data;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String mobile,
    required String className,
    required String password,
    required String deviceId,
  }) async {
    try {
      final response = await _client.post(
        '/api/auth/register',
        data: {
          'name': name,
          'email': email,
          'mobile': mobile,
          'class': className,
          'password': password,
          'deviceId': deviceId,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final success = data['success'] as bool? ?? true;
        final message = data['message'] as String? ?? 'Registration failed';
        if (!success) throw ApiException(message);
      }
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> checkForgotEmail(String email) async {
    try {
      final response = await _client.post(
        '/api/auth/forgot-password/check-email',
        data: {'email': email},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final success = data['success'] as bool? ?? true;
        final message = data['message'] as String? ?? 'Email check failed';
        if (!success) throw ApiException(message);
      }
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        '/api/auth/forgot-password/reset',
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final success = data['success'] as bool? ?? true;
        final message = data['message'] as String? ?? 'Password reset failed';
        if (!success) throw ApiException(message);
      }
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _client.post('/api/auth/logout');
    } on DioException {
      // Best-effort: the local session is cleared regardless of this call's outcome.
    }
  }
}
