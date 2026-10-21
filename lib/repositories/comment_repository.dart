import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/comment.dart';

class CommentRepository {
  CommentRepository(this._client);

  final ApiClient _client;

  Future<List<Comment>> fetchComments(String videoId) async {
    try {
      final response = await _client.get('/api/comments/video/$videoId');
      return _parseComments(response.data);
    } on DioException catch (e) {
      final error = mapDioError(e);
      throw error;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> postComment({
    required String videoId,
    required String message,
  }) async {
    try {
      await _client.post(
        '/api/comments',
        data: {'videoId': videoId, 'message': message},
      );
    } on DioException catch (e) {
      final error = mapDioError(e);
      throw error;
    }
  }

  List<Comment> _parseComments(dynamic body) {
    List<dynamic> rawList;
    if (body is Map && body['data'] is List) {
      rawList = body['data'] as List;
    } else if (body is Map &&
        body['data'] is Map &&
        (body['data'] as Map)['comments'] is List) {
      rawList = (body['data'] as Map)['comments'] as List;
    } else if (body is List) {
      rawList = body;
    } else {
      rawList = const [];
    }
    return rawList
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
