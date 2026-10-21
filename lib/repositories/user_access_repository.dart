import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/user_access_models.dart';

class UserAccessRepository {
  UserAccessRepository(this._client);

  final ApiClient _client;

  Future<UserAccessData> fetchUserAccess(String userId) async {
    try {
      final response = await _client.get('/api/user-access/$userId');
      final body = UserAccessResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return body.data;
    } on DioException catch (e) {
      final error = mapDioError(e);
      throw error;
    } catch (e) {
      rethrow;
    }
  }
}
