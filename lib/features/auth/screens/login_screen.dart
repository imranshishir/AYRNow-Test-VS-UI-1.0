import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/state/role_provider.dart';
import 'package:ayrnow/ui/shared/ayr_logo.dart';
import 'package:ayrnow/ui/shared/widgets/primary_button.dart';
import 'package:ayrnow/features/auth/screens/register_screen.dart';
import 'package:ayrnow/core/backend/providers/backend_providers.dart';
import 'package:ayrnow/core/api/providers/auth_controller_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static bool _isValidEmail(String value) {
    return RegExp(r'^[\w\-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value.trim());
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _loading = true);

    try {
      final useFirebase = ref.read(useFirebaseBackendProvider);

      if (useFirebase) {
        final authService = ref.read(firebaseAuthServiceProvider);
        await authService.login(email, password);
        if (!mounted) return;
        ref.read(isLoggedInProvider.notifier).state = true;
        ref.read(hasChosenRoleProvider.notifier).state = true;
      } else {
        // Use JWT backend (AuthController)
        final success = await ref.read(authControllerProvider.notifier).login(email, password);
        if (!mounted) return;
        if (success) {
          ref.read(hasChosenRoleProvider.notifier).state = true;
        } else {
          if (mounted) setState(() {
            _loading = false;
            _errorMessage = 'Invalid email or password. Try again.';
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Invalid email or password. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Center(child: AyrLogo(size: 80)),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back',
                  style: t.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter your email';
                    }
                    if (!_isValidEmail(v)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() => _errorMessage = null),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Enter your password';
                    }
                    if (v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() => _errorMessage = null),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: t.textTheme.bodySmall?.copyWith(
                      color: t.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Log in',
                  isLoading: _loading,
                  onPressed: _submit,
                  icon: Icons.login,
                ),
                const SizedBox(height: 24),
                if (kDebugMode)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Center(
                      child: TextButton(
                        onPressed: _loading
                            ? null
                            : () {
                                _emailController.text = 'test@test.com';
                                _passwordController.text = 'test123';
                                _submit();
                              },
                        child: Text(
                          'Use test account',
                          style: t.textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Create account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
