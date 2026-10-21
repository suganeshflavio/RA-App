import 'package:dio/dio.dart';

import '../auth/session_expired_notifier.dart';
import '../config/env.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  ApiClient._internal()
      : _storage = const SecureStorageService(),
        _dio = Dio(
          BaseOptions(
            baseUrl: Env.apiBaseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final isAuthCall =
              error.requestOptions.path.contains('/api/auth/login') ||
              error.requestOptions.path.contains('/api/auth/logout');
          if (error.response?.statusCode == 401 && !isAuthCall) {
            SessionExpiredNotifier.instance.notify();
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  factory ApiClient() => instance;

  final Dio _dio;
  final SecureStorageService _storage;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _dio.get(path, queryParameters: queryParameters);

  Future<Response<dynamic>> post(String path, {Object? data}) =>
      _dio.post(path, data: data);
}
