import 'package:dio/dio.dart';

/// Auth response: accessToken, refreshToken, userId, accountId, role
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String? userId;
  final String? accountId;
  final String? role;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
    this.accountId,
    this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['userId']?.toString(),
      accountId: json['accountId']?.toString(),
      role: json['role'] as String?,
    );
  }
}

/// Me response: accountId, userId, role, email, displayName
class MeResponse {
  final String accountId;
  final String userId;
  final String role;
  final String? email;
  final String? displayName;

  MeResponse({
    required this.accountId,
    required this.userId,
    required this.role,
    this.email,
    this.displayName,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    return MeResponse(
      accountId: json['accountId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      role: json['role'] as String? ?? '',
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
    );
  }
}

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
    required String accountName,
  }) async {
    final res = await _dio.post(
      '/api/v1/auth/register',
      data: {
        'email': email,
        'password': password,
        'displayName': displayName,
        'role': role,
        'accountName': accountName,
      },
    );
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/api/v1/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthResponse> refresh({required String refreshToken}) async {
    final res = await _dio.post(
      '/api/v1/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> logout({required String refreshToken}) async {
    await _dio.post(
      '/api/v1/auth/logout',
      data: {'refreshToken': refreshToken},
    );
  }

  Future<MeResponse> me() async {
    final res = await _dio.get('/api/v1/me');
    return MeResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
