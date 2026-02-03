import 'package:flutter/material.dart';
import 'package:ayrnow/features/community/models/community_models.dart';

import '../data/community_mock_data.dart';

class CommunityTransferInboxScreen extends StatelessWidget {
  const CommunityTransferInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = <_TransferRequest>[
      _TransferRequest(
        id: 'tr-001',
        tenant: CommunityMockData.tenantB,
        fromBuilding: 'Building A • Unit 2B',
        toBuilding: 'Building C • Unit 5A',
        ratingSummary: '4.6 ★ (12 reviews)',
        submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      _TransferRequest(
        id: 'tr-002',
        tenant: CommunityMockData.tenantA,
        fromBuilding: 'Building B • Unit 7C',
        toBuilding: 'Building A • Unit 1D',
        ratingSummary: '4.2 ★ (7 reviews)',
        submittedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tenant Transfers')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final r = requests[i];

          return Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        child: Text(
                          r.tenant.name.isNotEmpty ? r.tenant.name[0].toUpperCase() : '?',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.tenant.name, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(r.tenant.roleLabel, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.swap_horiz_rounded),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('From: ${r.fromBuilding}', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text('To: ${r.toBuilding}', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_outline_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(r.ratingSummary),
                      const Spacer(),
                      Text(_timeAgo(r.submittedAt), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Declined ${r.tenant.name} (mock).')),
                            );
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('DECLINE'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Approved ${r.tenant.name} (mock).')),
                            );
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('APPROVE'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _TransferRequest {
  final String id;
  final CommunityUser tenant;
  final String fromBuilding;
  final String toBuilding;
  final String ratingSummary;
  final DateTime submittedAt;

  _TransferRequest({
    required this.id,
    required this.tenant,
    required this.fromBuilding,
    required this.toBuilding,
    required this.ratingSummary,
    required this.submittedAt,
  });
}
