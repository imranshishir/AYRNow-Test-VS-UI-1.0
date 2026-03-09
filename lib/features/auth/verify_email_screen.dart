import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_email_api.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _tokenCtrl = TextEditingController();
  bool _verifying = false;
  String? _error;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _checkInitialToken();
  }

  void _checkInitialToken() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['token'] != null) {
      _tokenCtrl.text = args['token'].toString();
    }
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) {
      setState(() => _error = 'Enter the verification code from your email.');
      return;
    }
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      await verifyEmail(token);
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _success = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verified. You can sign in now.')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } on AuthEmailApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = 'Network error. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args = ModalRoute.of(context)?.settings.arguments;
    final email = args is Map ? args['email']?.toString() ?? '' : '';
    final message = args is Map ? args['message']?.toString() ?? '' : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: _success
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outlined, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('Email verified', style: theme.textTheme.titleLarge),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (message.isNotEmpty) ...[
                    Text(
                      message,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (email.isNotEmpty)
                    Text(
                      'We sent a verification link to $email',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _tokenCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Verification code',
                      hintText: 'Paste the code from the email link',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
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
                    onPressed: _verifying ? null : _verify,
                    child: _verifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verify'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
                    child: const Text('Back to Sign In'),
                  ),
                ],
              ),
            ),
    );
  }
}
