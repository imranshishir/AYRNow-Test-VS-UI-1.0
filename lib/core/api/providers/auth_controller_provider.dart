import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/models/user_role.dart';
import 'package:ayrnow/core/api/auth_token_store.dart';
import 'package:ayrnow/core/api/endpoints/auth_api.dart';
import 'package:ayrnow/core/api/providers/api_client_provider.dart';
import 'package:ayrnow/state/role_provider.dart';

/// Maps backend role string to Flutter UserRole
UserRole roleFromBackend(String? role) {
  if (role == null || role.isEmpty) return UserRole.tenant;
  switch (role.toLowerCase()) {
    case 'landlord':
      return UserRole.landlord;
    case 'tenant':
    case 'family':
    case 'cotenant':
    case 'co_tenant':
      return UserRole.tenant;
    case 'contractor':
      return UserRole.contractor;
    case 'security_guard':
      return UserRole.guard;
    default:
      return UserRole.tenant;
  }
}

String roleToBackend(UserRole role) {
  switch (role) {
    case UserRole.landlord:
      return 'landlord';
    case UserRole.tenant:
      return 'tenant';
    case UserRole.contractor:
      return 'contractor';
    case UserRole.guard:
      return 'security_guard';
  }
}

class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AuthController(this._ref) : super(const AsyncValue.data(null));

  AuthTokenStore get _tokenStore => _ref.read(authTokenStoreProvider);
  Dio get _dio => _ref.read(apiClientProvider);

  Future<void> clearSession() async {
    await _tokenStore.clear();
    _ref.read(isLoggedInProvider.notifier).state = false;
    _ref.read(hasChosenRoleProvider.notifier).state = false;
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final api = AuthApi(_dio);
      final res = await api.login(email: email, password: password);
      await _tokenStore.saveTokens(
        accessToken: res.accessToken,
        refreshToken: res.refreshToken,
        userId: res.userId,
        accountId: res.accountId,
        role: res.role,
      );
      _ref.read(isLoggedInProvider.notifier).state = true;
      _ref.read(currentRoleProvider.notifier).state = roleFromBackend(res.role);
      _ref.read(hasChosenRoleProvider.notifier).state = true;
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> register({
    required String displayName,
    required String email,
    required String password,
    required UserRole role,
    String accountName = 'Personal Account',
  }) async {
    state = const AsyncValue.loading();
    try {
      final api = AuthApi(_dio);
      final res = await api.register(
        email: email,
        password: password,
        displayName: displayName,
        role: roleToBackend(role),
        accountName: accountName.isEmpty ? 'Personal Account' : accountName,
      );
      await _tokenStore.saveTokens(
        accessToken: res.accessToken,
        refreshToken: res.refreshToken,
        userId: res.userId,
        accountId: res.accountId,
        role: res.role,
      );
      _ref.read(isLoggedInProvider.notifier).state = true;
      _ref.read(currentRoleProvider.notifier).state = roleFromBackend(res.role);
      _ref.read(hasChosenRoleProvider.notifier).state = true;
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStore.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        final api = AuthApi(_dio);
        await api.logout(refreshToken: refreshToken);
      } catch (_) {}
    }
    await clearSession();
  }

  Future<bool> hasValidSession() async {
    return await _tokenStore.hasTokens();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});
