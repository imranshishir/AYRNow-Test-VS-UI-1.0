import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ayrnow/core/models/role.dart';
import 'package:ayrnow/core/models/user.dart';
import 'package:ayrnow/core/state/providers.dart';
import 'package:ayrnow/ui/auth_gate.dart';

/// Phase 1 auth: minimal tests for gate and default state (no mock backend).
void main() {
  group('Auth Phase 1', () {
    test('currentUserProvider default is placeholder (no mock user)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final user = container.read(currentUserProvider);
      expect(user.id, '');
      expect(user.name, '');
      expect(user.role, UserRole.tenant);
    });

    testWidgets('AuthGate builds without throwing', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthGate(),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AuthGate), findsOneWidget);
    });
  });
}
