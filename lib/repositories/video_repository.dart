import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/video_lesson.dart';

class VideoRepository {
  VideoRepository(this._client);

  final ApiClient _client;

  Future<VideosData> fetchVideos({
    required String courseId,
    required String chapter,
  }) async {
    try {
      final response = await _client.get(
        '/api/videos',
        queryParameters: {'courseId': courseId, 'chapter': chapter},
      );
      final body = VideosResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      if (!body.success || body.data == null) {
        throw ApiException(body.message);
      }
      return body.data!;
    } on DioException catch (e) {
      final error = mapDioError(e);
      throw error;
    } catch (e) {
      rethrow;
    }
  }
}
