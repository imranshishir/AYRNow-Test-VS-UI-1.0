import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/backend/stripe_config.dart';
import 'ui/app_theme.dart';
import 'ui/auth_gate.dart';
import 'ui/app_shell.dart';
import 'ui/login_screen.dart';
import 'navigation/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isStripeConfigured) {
    Stripe.publishableKey = stripePublishableKey;
    await Stripe.instance.applySettings();
  }

  runApp(const ProviderScope(child: AyrnowApp()));
}

class AyrnowApp extends StatelessWidget {
  const AyrnowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AYRNOW Phase-2',
      theme: buildAyrnowTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const AppShell(),
        ...buildRoutes(),
      },
    );
  }
}
