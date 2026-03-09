import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_email_api.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _readTokenFromRoute();
  }

  void _readTokenFromRoute() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['token'] != null) {
      _tokenCtrl.text = args['token'].toString();
    }
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) {
      setState(() => _error = 'Reset code is required.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await resetPassword(token: token, newPassword: _passwordCtrl.text);
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _success = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset. You can sign in now.')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } on AuthEmailApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: _success
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outlined, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('Password reset', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Enter the code from your email and choose a new password.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _tokenCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Reset code',
                        hintText: 'Paste the code from the email link',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(
                        labelText: 'New password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.length < 8) return 'At least 8 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Confirm new password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v != _passwordCtrl.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_error != null) ...[
                      Card(
                        color: theme.colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Reset Password'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
                      child: const Text('Back to Sign In'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
