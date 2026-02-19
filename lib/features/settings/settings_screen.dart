import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/backend/api_base_url.dart';
import '../../core/state/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _baseUrlController = TextEditingController();
  String _resolvedDefault = '';
  bool _loadingDefault = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentBaseUrl();
  }

  Future<void> _loadCurrentBaseUrl() async {
    final override = await getApiBaseUrlOverride();
    final resolved = await resolveApiBaseUrl();
    if (mounted) {
      setState(() {
        _baseUrlController.text = override ?? resolved;
        _resolvedDefault = resolved;
        _loadingDefault = false;
      });
    }
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (kDebugMode) ...[
            const Text('Dev', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('API Base URL', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    if (_loadingDefault)
                      const SizedBox(height: 48, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                    else
                      TextField(
                        controller: _baseUrlController,
                        decoration: const InputDecoration(
                          hintText: 'http://127.0.0.1:8080',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.url,
                        autocorrect: false,
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton(
                          onPressed: _loadingDefault
                              ? null
                              : () async {
                                  await saveApiBaseUrlOverride(_baseUrlController.text.trim().isEmpty ? null : _baseUrlController.text.trim());
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
                                },
                          child: const Text('Save'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _loadingDefault
                              ? null
                              : () async {
                                  await saveApiBaseUrlOverride(null);
                                  _baseUrlController.text = _resolvedDefault;
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset to default')));
                                },
                          child: const Text('Reset to default'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Default: $_resolvedDefault (iOS Simulator: use Mac LAN IP if 127.0.0.1 fails)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              subtitle: const Text('Clear session and return to login'),
              onTap: () async {
                await ref.read(authControllerProvider).logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
