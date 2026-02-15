import 'package:ayrnow/core/models/user_role.dart';

class MockAuthService {
  MockAuthService._();

  static const _failEmail = 'error@test.com';

  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.trim().toLowerCase() == _failEmail) return false;
    return password.length >= 6;
  }

  static Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (email.trim().toLowerCase() == _failEmail) return false;
    return name.trim().isNotEmpty && password.length >= 6;
  }

  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
