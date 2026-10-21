import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/user_access_models.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_access_repository.dart';
import '../utils/device_info.dart';

class SessionState extends ChangeNotifier {
  SessionState({
    AuthRepository? authRepository,
    UserAccessRepository? userAccessRepository,
    SecureStorageService? storage,
  }) : _authRepository = authRepository ?? AuthRepository(ApiClient()),
       _userAccessRepository =
           userAccessRepository ?? UserAccessRepository(ApiClient()),
       _storage = storage ?? const SecureStorageService();

  final AuthRepository _authRepository;
  final UserAccessRepository _userAccessRepository;
  final SecureStorageService _storage;

  UserProfile? _user;
  String? _token;
  List<UserCourse> _courses = [];
  bool _isRestoring = true;
  bool _isLoggingIn = false;
  bool _isLoadingCourses = false;
  String? _errorMessage;

  UserProfile? get user => _user;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  List<UserCourse> get courses => List.unmodifiable(_courses);
  bool get isRestoring => _isRestoring;
  bool get isLoggingIn => _isLoggingIn;
  bool get isLoadingCourses => _isLoadingCourses;
  String? get errorMessage => _errorMessage;

  Future<void> restoreSession() async {
    _isRestoring = true;
    final token = await _storage.readToken();
    final user = await _storage.readUser();
    if (token != null && token.isNotEmpty && user != null) {
      _token = token;
      _user = user;
      await loadUserAccess(userId: user.id);
    }
    _isRestoring = false;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoggingIn = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final deviceId = await getDeviceId();
      final result = await _authRepository.login(
        email: email,
        password: password,
        deviceId: deviceId,
      );
      _token = result.token;
      _user = result.user;
      await _storage.saveToken(result.token);
      await _storage.saveUser(result.user);
      await loadUserAccess(userId: result.user.id, forceRefresh: true);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoggingIn = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String mobile,
    required String className,
    required String password,
  }) async {
    _isLoggingIn = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final deviceId = await getDeviceId();
      await _authRepository.register(
        name: name,
        email: email,
        mobile: mobile,
        className: className,
        password: password,
        deviceId: deviceId,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoggingIn = false;
      notifyListeners();
    }
  }

  Future<void> loadUserAccess({
    required String userId,
    bool forceRefresh = false,
  }) async {
    if (_courses.isNotEmpty && !forceRefresh) return;
    _isLoadingCourses = true;
    notifyListeners();
    try {
      final data = await _userAccessRepository.fetchUserAccess(userId);
      _courses = data.courses;
      _user = data.user;
      await _storage.saveUser(data.user);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Unable to load courses.';
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  Future<void> refreshCourses() async {
    final id = _user?.id;
    if (id != null) await loadUserAccess(userId: id, forceRefresh: true);
  }

  Future<void> logout() async {
    await _authRepository.logout();
    await _storage.clear();
    _token = null;
    _user = null;
    _courses = [];
    _errorMessage = null;
    notifyListeners();
  }
}
