import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/notes_item.dart';

class NotesRepository {
  NotesRepository(this._client);

  final ApiClient _client;

  Future<NotesItem> fetchNotesById(String notesId) async {
    try {
      final response = await _client.get('/api/notes/$notesId');
      final body = NotesResponse.fromJson(
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
