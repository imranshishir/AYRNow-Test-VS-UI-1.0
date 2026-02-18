import 'package:dio/dio.dart';
import 'package:ayrnow/core/api/auth_token_store.dart';

/// Adds Bearer token to requests. Requires AuthTokenStore.
class AuthInterceptor extends Interceptor {
  final AuthTokenStore tokenStore;

  AuthInterceptor(this.tokenStore);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenStore.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
