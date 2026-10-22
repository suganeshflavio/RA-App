import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/video_lesson.dart';

class VideoRepository {
  VideoRepository(this._client);

  final ApiClient _client;

  Future<VideoLesson> fetchVideoById(String videoId) async {
    try {
      final response = await _client.get('/api/videos/$videoId');
      final body = VideoResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      if (!body.success || body.data == null) {
        throw ApiException(body.message, statusCode: response.statusCode);
      }
      return body.data!;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
