import 'package:dio/dio.dart';
import 'package:ayrnow/core/api/api_config.dart';
import 'package:ayrnow/core/api/auth_token_store.dart';
import 'package:ayrnow/core/api/models/error_response.dart';
import 'package:ayrnow/core/api/interceptors/auth_interceptor.dart';
import 'package:ayrnow/core/api/interceptors/refresh_interceptor.dart';
import 'package:ayrnow/core/api/interceptors/idempotency_interceptor.dart';

/// Dio-based API client with auth, refresh, and idempotency interceptors.
Dio createApiClient({
  required AuthTokenStore tokenStore,
  required Future<void> Function() onLogout,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(IdempotencyInterceptor());
  dio.interceptors.add(AuthInterceptor(tokenStore));
  dio.interceptors.add(
    RefreshInterceptor(dio: dio, tokenStore: tokenStore, onLogout: onLogout),
  );

  dio.interceptors.add(InterceptorsWrapper(
    onResponse: (response, handler) => handler.next(response),
    onError: (err, handler) {
      if (err.response?.data is Map<String, dynamic>) {
        try {
          final er = ErrorResponse.fromJson(
            err.response!.data as Map<String, dynamic>,
          );
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              error: er.toException(err.response?.statusCode),
            ),
          );
        } catch (_) {}
      }
      handler.next(err);
    },
  ));

  return dio;
}
