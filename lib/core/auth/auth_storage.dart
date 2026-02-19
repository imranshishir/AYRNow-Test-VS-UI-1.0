import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _keyAuthToken = 'authToken';

/// Persists JWT in secure storage (no SharedPreferences).
class AuthStorage {
  AuthStorage() : _storage = const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  final FlutterSecureStorage _storage;

  Future<String?> readToken() => _storage.read(key: _keyAuthToken);

  Future<void> writeToken(String token) => _storage.write(key: _keyAuthToken, value: token);

  Future<void> clearToken() => _storage.delete(key: _keyAuthToken);
}
