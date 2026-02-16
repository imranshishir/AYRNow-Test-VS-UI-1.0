import 'package:flutter/material.dart';
import 'package:ayrnow/features/contractor/screens/c_models.dart';

class ContractorJobDetailScreen extends StatefulWidget {
  final ContractorJob job;
  const ContractorJobDetailScreen({super.key, required this.job});

  @override
  State<ContractorJobDetailScreen> createState() => _ContractorJobDetailScreenState();
}

class _ContractorJobDetailScreenState extends State<ContractorJobDetailScreen> {
  late String _status;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _status = widget.job.status;
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.job;

    return Scaffold(
      appBar: AppBar(title: Text(j.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${j.propertyName} • ${j.unitLabel}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(j.address, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Chip(label: Text(j.category)),
                      const SizedBox(width: 8),
                      Chip(label: Text('Priority: ${j.priority}')),
                      const Spacer(),
                      Chip(label: Text(_status)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Scheduled: ${j.scheduledLabel}', style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Issue details', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(j.description),
            ),
          ),
          const SizedBox(height: 14),
          Text('Work actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _setStatus('Accepted'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Accept'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _setStatus('In Progress'),
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Start'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => _setStatus('Completed'),
            icon: const Icon(Icons.verified_outlined),
            label: const Text('Mark completed'),
          ),

          const SizedBox(height: 14),
          _ActionTile(
            icon: Icons.photo_camera_outlined,
            title: 'Upload photos (next)',
            subtitle: 'Before/after photos for landlord approval.',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Next: Photo upload screen')),
            ),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.receipt_long_outlined,
            title: 'Create invoice (next)',
            subtitle: 'Labor + materials + total. Submit to landlord.',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Next: Invoice builder screen')),
            ),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.chat_bubble_outline,
            title: 'Message landlord/tenant (next)',
            subtitle: 'Chat thread for this job.',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Next: Job chat screen')),
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
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _status = next;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated: $next')),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
