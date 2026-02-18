import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/providers.dart';

class TenantTransferRequestScreen extends ConsumerStatefulWidget {
  const TenantTransferRequestScreen({super.key});

  @override
  ConsumerState<TenantTransferRequestScreen> createState() => _TenantTransferRequestScreenState();
}

class _TenantTransferRequestScreenState extends ConsumerState<TenantTransferRequestScreen> {
  final _targetController = TextEditingController();
  final _noteController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _targetController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _targetController.text.trim().isNotEmpty && !_loading;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final controller = ref.read(transferRequestControllerProvider);
      await controller.createTransferRequest(
        targetEmailOrCode: _targetController.text.trim(),
        note: _noteController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    } finally {
      if (mounted && _loading) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('T-45 • Request Transfer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Send your portable profile to a new landlord.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _targetController,
            decoration: const InputDecoration(
              labelText: 'Landlord email or invite code *',
              hintText: 'email@example.com or INVITE-ABC123',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'Brief message to the landlord',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),

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
            const SizedBox(height: 12),
          ],

          FilledButton.icon(
            onPressed: _canSubmit ? _submit : null,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(_loading ? 'Sending…' : 'Submit Request'),
          ),
        ],
      ),
    );
  }
}
