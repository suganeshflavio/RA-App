import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/student_test.dart';

class StudentTestRepository {
  StudentTestRepository(this._client);

  final ApiClient _client;

  Future<List<StudentTest>> fetchTestsByVideo(String videoId) async {
    try {
      final response = await _client.get('/api/tests/student/video/$videoId');
      final body = StudentTestListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      if (!body.success) {
        throw ApiException(body.message, statusCode: response.statusCode);
      }
      return body.data;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<StudentTest> fetchTestById(String testId) async {
    try {
      final response = await _client.get('/api/tests/student/$testId');
      final body = StudentTestResponse.fromJson(
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

  Future<StudentAttemptResult> submitAttempt({
    required String testId,
    required String videoId,
    required DateTime startedAt,
    required DateTime submittedAt,
    required List<AttemptAnswer> answers,
    String status = 'COMPLETED',
  }) async {
    final payload = {
      'videoId': videoId,
      'status': status,
      'startedAt': startedAt.toUtc().toIso8601String(),
      'submittedAt': submittedAt.toUtc().toIso8601String(),
      'answers': answers
          .map((answer) => answer.toJson())
          .toList(growable: false),
    };

    try {
      final response = await _client.post(
        '/api/tests/$testId/attempts',
        data: payload,
      );
      final body = SubmitAttemptResponse.fromJson(
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

class AttemptAnswer {
  const AttemptAnswer({required this.questionId, required this.selected});

  final String questionId;
  final String selected;

  Map<String, String> toJson() => {
    'questionId': questionId,
    'selected': selected,
  };
}
