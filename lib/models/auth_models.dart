import 'user_profile.dart';

class LoginResponse {
  const LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final LoginData data;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    success: json['success'] as bool,
    message: json['message'] as String,
    data: LoginData.fromJson(json['data'] as Map<String, dynamic>),
  );
}

class LoginData {
  const LoginData({required this.token, required this.user});

  final String token;
  final UserProfile user;

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
    token: json['token'] as String,
    user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
  );
}
