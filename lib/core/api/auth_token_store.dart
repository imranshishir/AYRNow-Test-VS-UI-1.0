import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for JWT tokens and user context.
class AuthTokenStore {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _accountIdKey = 'account_id';
  static const _roleKey = 'role';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);
  Future<String?> getUserId() => _storage.read(key: _userIdKey);
  Future<String?> getAccountId() => _storage.read(key: _accountIdKey);
  Future<String?> getRole() => _storage.read(key: _roleKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? accountId,
    String? role,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    if (userId != null) await _storage.write(key: _userIdKey, value: userId);
    if (accountId != null) await _storage.write(key: _accountIdKey, value: accountId);
    if (role != null) await _storage.write(key: _roleKey, value: role);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _accountIdKey);
    await _storage.delete(key: _roleKey);
  }

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
