import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:ayrnow/core/api/api_client.dart';
import 'package:ayrnow/core/api/auth_token_store.dart';
import 'package:ayrnow/state/role_provider.dart';

final authTokenStoreProvider = Provider<AuthTokenStore>((ref) {
  return AuthTokenStore();
});

final apiClientProvider = Provider<Dio>((ref) {
  final tokenStore = ref.watch(authTokenStoreProvider);
  Future<void> onLogout() async {
    await tokenStore.clear();
    ref.read(isLoggedInProvider.notifier).state = false;
    ref.read(hasChosenRoleProvider.notifier).state = false;
  }
  return createApiClient(tokenStore: tokenStore, onLogout: onLogout);
});
