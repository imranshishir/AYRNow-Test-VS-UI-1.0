import 'package:dio/dio.dart';
import 'package:ayrnow/core/api/auth_token_store.dart';

/// On 401, attempt refresh once, then retry original request. If refresh fails, call onLogout.
class RefreshInterceptor extends QueuedInterceptor {
  final Dio dio;
  final AuthTokenStore tokenStore;
  final Future<void> Function() onLogout;

  RefreshInterceptor({
    required this.dio,
    required this.tokenStore,
    required this.onLogout,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final refreshToken = await tokenStore.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await tokenStore.clear();
      onLogout();
      return handler.next(err);
    }

    try {
      final refreshResp = await dio.post(
        '${err.requestOptions.baseUrl}/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (_) => true,
        ),
      );

      if (refreshResp.statusCode != 200) {
        await tokenStore.clear();
        onLogout();
        return handler.next(err);
      }

      final data = refreshResp.data as Map<String, dynamic>?;
      final accessToken = data?['accessToken'] as String?;
      final newRefresh = data?['refreshToken'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        await tokenStore.clear();
        onLogout();
        return handler.next(err);
      }

      await tokenStore.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefresh ?? refreshToken,
        userId: data?['userId']?.toString(),
        accountId: data?['accountId']?.toString(),
        role: data?['role'] as String?,
      );

      final opts = err.requestOptions
        ..headers['Authorization'] = 'Bearer $accessToken';
      final retryResp = await dio.fetch(opts);
      return handler.resolve(Response(
        requestOptions: opts,
        data: retryResp.data,
        statusCode: retryResp.statusCode,
      ));
    } catch (_) {
      await tokenStore.clear();
      onLogout();
      return handler.next(err);
    }
  }
}
