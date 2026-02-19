import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/state/providers.dart';
import '../core/models/role.dart';
import '../core/models/user.dart';
import '../core/backend/api_base_url.dart';

/// Login via POST /v1/auth/login. Creates user if not exists (dev-friendly).
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
      final body = {
        'email': email,
        'role': _role.name,
        if (_nameController.text.trim().isNotEmpty) 'name': _nameController.text.trim(),
      };
      final baseUrl = await resolveApiBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/v1/auth/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final token = json['token'] as String?;
        if (token != null && token.isNotEmpty) {
          ref.read(authTokenProvider.notifier).state = token;
          ref.read(currentUserProvider.notifier).state = AppUser(
            id: json['userId'] as String? ?? '',
            name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : (json['email'] as String? ?? email).split('@').first,
            role: _role,
          );
          ref.invalidate(meProvider);
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() => _error = 'Invalid response from server');
        }
      } else {
        String msg = 'Login failed';
        try {
          final j = jsonDecode(response.body) as Map<String, dynamic>?;
          msg = (j?['message'] ?? j?['error'])?.toString() ?? msg;
        } catch (_) {}
        setState(() => _error = msg);
      }
    } catch (e) {
      setState(() => _error = 'Network error: $e');
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
