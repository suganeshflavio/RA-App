import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/testimonial.dart';

class TestimonialRepository {
  TestimonialRepository(this._client);

  final ApiClient _client;

  Future<void> submitTestimonial({
    required int star,
    required String review,
  }) async {
    try {
      final response = await _client.post(
        '/api/testimonials',
        data: {'star': star, 'review': review},
      );
      final body = response.data;
      final success = body is Map && body['success'] == true;
      if (!success) {
        final message = body is Map && body['message'] is String
            ? body['message'] as String
            : 'Unable to submit your review.';
        throw ApiException(message);
      }
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Testimonial>> fetchPublicTestimonials() async {
    try {
      final response = await _client.get('/api/testimonials/public');
      return _parseTestimonials(response.data);
    } on DioException catch (e) {
      final error = mapDioError(e);
      throw error;
    } catch (e) {
      rethrow;
    }
  }

  List<Testimonial> _parseTestimonials(dynamic body) {
    List<dynamic> rawList;
    if (body is Map && body['data'] is List) {
      rawList = body['data'] as List;
    } else if (body is Map && body['data'] is Map) {
      final data = body['data'] as Map;
      rawList =
          (data['testimonials'] as List<dynamic>?) ??
          (data['reviews'] as List<dynamic>?) ??
          const [];
    } else if (body is List) {
      rawList = body;
    } else {
      rawList = const [];
    }
    return rawList
        .map((e) => Testimonial.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
