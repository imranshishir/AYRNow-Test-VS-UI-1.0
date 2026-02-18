import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Adds Idempotency-Key header to ledger write requests.
class IdempotencyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.uri.path;
    if (options.method == 'POST' &&
        path.startsWith('/api/v1/ledger/') &&
        (path.endsWith('/charges') ||
            path.endsWith('/payments') ||
            path.endsWith('/refunds') ||
            path.endsWith('/adjustments'))) {
      options.headers['Idempotency-Key'] = _uuid.v4();
    }
    handler.next(options);
  }
}
