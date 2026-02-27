import 'package:ayrnow/core/state/providers.dart';
import 'package:ayrnow/features/tenant/t10_pay_rent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PayRentScreen disables button when Stripe is not configured',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PayRentScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Card payments are not enabled'), findsOneWidget);
  });

  testWidgets('PayRentScreen shows amount due from provider',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tenantAmountDueProvider.overrideWith((ref) => 2000.0),
        ],
        child: const MaterialApp(
          home: PayRentScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('\$2000'), findsOneWidget);
  });
}

