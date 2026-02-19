import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/state/providers.dart';
import '../core/models/role.dart';

/// Login via AuthController (POST /v1/auth/login + persist token). Creates user if not exists (dev-friendly).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  UserRole _role = UserRole.tenant;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Email is required');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref.read(authControllerProvider).login(
            email: email,
            role: _role,
            name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
          );
      if (!mounted) return;
      if (result != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _error = 'Login failed');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Network error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            Image.asset(
              'assets/logo/ayrnow_logo.png',
              height: 28,
              errorBuilder: (_, __, ___) => const Icon(Icons.home_work_outlined),
            ),
            const SizedBox(width: 10),
            const Text('AYRNOW'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Sign in', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Enter your email and role to continue.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email *',
              hintText: 'you@example.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name (optional)',
              hintText: 'Your display name',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<UserRole>(
            value: _role,
            decoration: const InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: UserRole.tenant, child: Text('Tenant')),
              DropdownMenuItem(value: UserRole.landlord, child: Text('Landlord')),
            ],
            onChanged: (v) => setState(() => _role = v ?? _role),
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          FilledButton.icon(
            onPressed: _loading ? null : _login,
            icon: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.login),
            label: Text(_loading ? 'Signing in…' : 'Sign in'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ],
      ),
    );
  }
}
