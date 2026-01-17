import 'package:flutter/material.dart';
import 'package:ayrnow/features/guard/screens/g_models.dart';

class GuardApprovalDetailScreen extends StatefulWidget {
  final GuardApproval approval;
  const GuardApprovalDetailScreen({super.key, required this.approval});

  @override
  State<GuardApprovalDetailScreen> createState() =>
      _GuardApprovalDetailScreenState();
}

class _GuardApprovalDetailScreenState extends State<GuardApprovalDetailScreen> {
  late String _status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _status = widget.approval.status;
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.approval;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(a.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${a.propertyName} • ${a.unitLabel}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Entry point: ${a.entryPoint}',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Chip(label: Text(a.visitorType)),
                      const SizedBox(width: 8),
                      Chip(label: Text('ETA: ${a.etaLabel}')),
                      const Spacer(),
                      Chip(label: Text(_status)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Visitor', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Icon(Icons.person, color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.visitorName,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text('Type: ${a.visitorType}',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Notes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(14), child: Text(a.notes))),
          const SizedBox(height: 14),
          Text('Action', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          if (_status == 'Pending') ...[
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : () => _setStatus('Approved'),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Approve entry'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _setStatus('Denied'),
              icon: const Icon(Icons.block_outlined),
              label: const Text('Deny entry'),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.surfaceContainerHighest,
              ),
              child: Row(
                children: [
                  Icon(_status == 'Approved'
                      ? Icons.verified_outlined
                      : Icons.block_outlined),
                  const SizedBox(width: 10),
                  Expanded(child: Text('This request is already $_status.')),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          _Tile(
            icon: Icons.badge_outlined,
            title: 'Verify ID (next)',
            subtitle: 'Scan/verify visitor ID (HIFI skeleton next).',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Next: ID verify / scan screen')),
            ),
          ),
          const SizedBox(height: 10),
          _Tile(
            icon: Icons.photo_camera_outlined,
            title: 'Capture photo (next)',
            subtitle: 'Optional visitor photo for records.',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Next: photo capture screen')),
            ),
          ),
          const SizedBox(height: 10),
          _Tile(
            icon: Icons.note_add_outlined,
            title: 'Add incident note (next)',
            subtitle: 'Log any incident or unusual activity.',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Next: incident note screen')),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),
        ],
      ),
    );
  }

  Future<void> _setStatus(String next) async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _status = next;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Status updated: $next')));
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _Tile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cs.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: cs.primaryContainer,
              ),
              child: Icon(icon, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ]),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
