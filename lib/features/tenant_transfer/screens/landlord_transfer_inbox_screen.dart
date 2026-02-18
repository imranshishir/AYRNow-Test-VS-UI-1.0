import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/state/providers.dart';
import '../models/tenant_transfer_models.dart';
import 'landlord_transfer_request_detail_screen.dart';

class LandlordTransferInboxScreen extends ConsumerStatefulWidget {
  const LandlordTransferInboxScreen({super.key});

  @override
  ConsumerState<LandlordTransferInboxScreen> createState() => _LandlordTransferInboxScreenState();
}

class _LandlordTransferInboxScreenState extends ConsumerState<LandlordTransferInboxScreen> {
  String _filter = 'pending';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requestsAsync = ref.watch(landlordTransferInboxProvider(_filter));

    return Scaffold(
      appBar: AppBar(title: const Text('L-45 • Transfer Requests')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Pending',
                  selected: _filter == 'pending',
                  onTap: () => setState(() => _filter = 'pending'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Accepted',
                  selected: _filter == 'accepted',
                  onTap: () => setState(() => _filter = 'accepted'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Rejected',
                  selected: _filter == 'rejected',
                  onTap: () => setState(() => _filter = 'rejected'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: requestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 16),
                      Text(err.toString(), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              data: (requests) {
                if (requests.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _filter == 'pending'
                            ? 'No pending transfer requests.'
                            : 'No ${_filter} requests.',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (_, i) {
                    final r = requests[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(r.tenantName),
                        subtitle: Text(
                          '${DateFormat.yMMMd().format(r.createdAt)} • ${r.note.length > 50 ? '${r.note.substring(0, 50)}…' : r.note}',
                        ),
                        trailing: _StatusPill(status: r.status),
                        onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LandlordTransferRequestDetailScreen(request: r),
                              ),
                            ).then((_) => ref.invalidate(landlordTransferInboxProvider)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
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
      child: Text(status.label, style: TextStyle(fontSize: 12, color: color)),
    );
  }
}
