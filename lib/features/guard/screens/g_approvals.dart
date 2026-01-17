import 'package:flutter/material.dart';
import 'package:ayrnow/features/guard/screens/g_models.dart';
import 'package:ayrnow/features/guard/screens/g_approval_detail.dart';

class GuardApprovalsScreen extends StatelessWidget {
  const GuardApprovalsScreen({super.key});

  static const approvals = <GuardApproval>[
    GuardApproval(
      id: 'A-2201',
      propertyName: 'Harlem Heights',
      entryPoint: 'Lobby',
      unitLabel: 'Apt 2B',
      visitorName: 'John Smith',
      visitorType: 'Guest',
      etaLabel: 'Now',
      status: 'Pending',
      notes: 'Tenant expects guest for dinner.',
    ),
    GuardApproval(
      id: 'A-2202',
      propertyName: 'Elmwood Plaza',
      entryPoint: 'Service Door',
      unitLabel: 'Store 12',
      visitorName: 'UPS Delivery',
      visitorType: 'Delivery',
      etaLabel: '10 min',
      status: 'Pending',
      notes: 'Signature required at store.',
    ),
    GuardApproval(
      id: 'A-2203',
      propertyName: 'Lakeview Villas',
      entryPoint: 'Main Gate',
      unitLabel: 'Apt 03',
      visitorName: 'HVAC Contractor',
      visitorType: 'Contractor',
      etaLabel: '2:30 PM',
      status: 'Approved',
      notes: 'Work order #J-1003',
    ),
    GuardApproval(
      id: 'A-2204',
      propertyName: 'Harlem Heights',
      entryPoint: 'Lobby',
      unitLabel: 'Apt 1A',
      visitorName: 'Unknown Visitor',
      visitorType: 'Guest',
      etaLabel: 'Earlier',
      status: 'Denied',
      notes: 'Not on approved list.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        Row(
          children: [
            Expanded(
                child: Text('Approvals',
                    style: Theme.of(context).textTheme.titleLarge)),
            FilledButton.tonalIcon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Next: search + filter by property/unit/status')),
              ),
              icon: const Icon(Icons.tune),
              label: const Text('Filter'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...approvals.map((a) => _ApprovalCard(approval: a)),
      ],
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final GuardApproval approval;
  const _ApprovalCard({required this.approval});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color badgeBg;
    Color badgeFg;
    if (approval.status == 'Pending') {
      badgeBg = cs.tertiaryContainer;
      badgeFg = cs.onTertiaryContainer;
    } else if (approval.status == 'Approved') {
      badgeBg = cs.secondaryContainer;
      badgeFg = cs.onSecondaryContainer;
    } else {
      badgeBg = cs.errorContainer;
      badgeFg = cs.onErrorContainer;
    }

    IconData typeIcon = Icons.person_outline;
    if (approval.visitorType == 'Delivery')
      typeIcon = Icons.local_shipping_outlined;
    if (approval.visitorType == 'Contractor')
      typeIcon = Icons.handyman_outlined;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => GuardApprovalDetailScreen(approval: approval)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${approval.propertyName} • ${approval.unitLabel}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: badgeBg),
                    child:
                        Text(approval.status, style: TextStyle(color: badgeFg)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(typeIcon, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          '${approval.visitorName} • ${approval.visitorType}')),
                  Text(approval.etaLabel,
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 8),
              Text('Entry: ${approval.entryPoint}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
