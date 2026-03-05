import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/main.dart';
import 'package:ayrnow/core/state/providers.dart';
import 'package:ayrnow/ui/login_screen.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Resolve session immediately with no user so gate shows LoginScreen (no hang on /v1/me).
          initialSessionProvider.overrideWith((ref) => Future.value(null)),
        ],
        child: const AyrnowApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
