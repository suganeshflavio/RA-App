import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

ApiException mapDioError(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['message'] is String) {
    return ApiException(
      data['message'] as String,
      statusCode: e.response?.statusCode,
    );
  }
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return ApiException('Request timed out. Please try again.');
    case DioExceptionType.connectionError:
      return ApiException('No internet connection.');
    default:
      return ApiException(
        'Something went wrong. Please try again.',
        statusCode: e.response?.statusCode,
      );
  }
}
