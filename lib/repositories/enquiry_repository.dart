import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/enquiry.dart';

class EnquiryRepository {
  EnquiryRepository([ApiClient? client]) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<String?> submitEnquiry(EnquiryRequest request) async {
    try {
      final response = await _client.post(
        '/api/enquiries',
        data: request.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final success = data['success'] as bool? ?? true;
        final message = data['message'] as String?;
        if (!success) {
          throw ApiException(message ?? 'Failed to submit enquiry.');
        }
        return message;
      }
      return null;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
