import 'package:dio/dio.dart';

class PaymentsApi {
  final Dio _dio;

  PaymentsApi(this._dio);

  Future<Map<String, dynamic>> createCheckoutSession({
    required String unitId,
    required String leaseId,
    required int amountCents,
  }) async {
    final res = await _dio.post(
      '/api/v1/payments/stripe/checkout-session',
      data: {
        'unitId': unitId,
        'leaseId': leaseId,
        'amountCents': amountCents,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPaymentHistory({
    required String unitId,
    int page = 0,
    int size = 20,
  }) async {
    final res = await _dio.get(
      '/api/v1/payments/history',
      queryParameters: {'unitId': unitId, 'page': page, 'size': size},
    );
    return res.data as Map<String, dynamic>;
  }
}
