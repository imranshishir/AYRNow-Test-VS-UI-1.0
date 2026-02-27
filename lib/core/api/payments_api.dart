import '../backend/dtos/payments_dto.dart';
import 'api_client.dart';

class PaymentsApi {
  PaymentsApi(this._client);

  final ApiClient _client;

  Future<PaymentIntentDto> createPaymentIntent({
    required String unitId,
    required int amountDollars,
    int? amountCents,
  }) async {
    final body = <String, dynamic>{
      'unitId': unitId,
      if (amountCents != null) 'amountCents': amountCents,
      if (amountDollars > 0) 'amount': amountDollars,
    };

    final json = await _client.postJson('/v1/payments/intent', body: body);
    if (json is! Map<String, dynamic>) {
      throw StateError('Unexpected payments/intent response');
    }
    return PaymentIntentDto.fromJson(json);
  }
}

