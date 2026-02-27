import 'package:ayrnow/core/backend/dtos/payments_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PaymentIntentDto parses basic fields', () {
    final dto = PaymentIntentDto.fromJson({
      'paymentId': 'p123',
      'status': 'pending',
      'clientSecret': 'cs_test_123',
    });

    expect(dto.paymentId, 'p123');
    expect(dto.status, 'pending');
    expect(dto.clientSecret, 'cs_test_123');
  });

  test('PaymentIntentDto handles missing optional clientSecret', () {
    final dto = PaymentIntentDto.fromJson({
      'paymentId': 'p456',
      'status': 'stubbed',
    });

    expect(dto.paymentId, 'p456');
    expect(dto.status, 'stubbed');
    expect(dto.clientSecret, isNull);
  });
}

