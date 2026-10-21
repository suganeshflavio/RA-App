import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/user_profile.dart';

class SecureStorageService {
  const SecureStorageService();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveUser(UserProfile user) =>
      _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

  Future<UserProfile?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clear() => _storage.deleteAll();
}
