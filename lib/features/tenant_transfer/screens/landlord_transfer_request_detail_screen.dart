import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/state/providers.dart';
import '../models/tenant_transfer_models.dart';

class LandlordTransferRequestDetailScreen extends ConsumerStatefulWidget {
  final TransferRequest request;

  const LandlordTransferRequestDetailScreen({super.key, required this.request});

  @override
  ConsumerState<LandlordTransferRequestDetailScreen> createState() =>
      _LandlordTransferRequestDetailScreenState();
}

class _LandlordTransferRequestDetailScreenState extends ConsumerState<LandlordTransferRequestDetailScreen> {
  final _messageController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _decide(bool accept) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final controller = ref.read(transferRequestControllerProvider);
      await controller.decideTransferRequest(
        requestId: widget.request.id,
        accept: accept,
        landlordMessage: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
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
    final r = widget.request;
    final canDecide = r.status == TransferRequestStatus.pending && !_loading;

    return Scaffold(
      appBar: AppBar(title: Text('Transfer: ${r.tenantName}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(r.tenantName, style: theme.textTheme.titleMedium),
                      const Spacer(),
                      _StatusPill(status: r.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('From: ${r.targetEmailOrCode}', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text('Requested ${DateFormat.yMMMd().add_Hm().format(r.createdAt)}', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Text(r.note, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile snapshot', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  const ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person_outline),
                    title: Text('Tenant profile summary'),
                    subtitle: Text('Verified history, payment score, reviews (mock data for v1)'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (canDecide) ...[
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message to tenant (optional)',
                hintText: 'E.g., Welcome! We\'ll send a lease for your review.',
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
                      const SizedBox(width: 10),
                      Expanded(child: Text(_error!)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _decide(false),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _decide(true),
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ] else ...[
            if (r.decidedAt != null)
              Text('Decided ${DateFormat.yMMMd().format(r.decidedAt!)}', style: theme.textTheme.bodySmall),
            if (r.landlordMessage != null && r.landlordMessage!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Message: ${r.landlordMessage}', style: theme.textTheme.bodyMedium),
            ],
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final TransferRequestStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == TransferRequestStatus.pending
        ? Colors.orange
        : status == TransferRequestStatus.accepted
            ? Colors.green
            : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
