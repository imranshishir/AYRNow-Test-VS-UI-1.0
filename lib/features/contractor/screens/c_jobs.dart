import 'package:flutter/material.dart';
import 'package:ayrnow/features/contractor/screens/c_models.dart';
import 'package:ayrnow/features/contractor/screens/c_job_detail.dart';

class ContractorJobsScreen extends StatelessWidget {
  const ContractorJobsScreen({super.key});

  static const jobs = <ContractorJob>[
    ContractorJob(
      id: 'J-1001',
      propertyName: 'Harlem Heights',
      unitLabel: 'Apt 2B',
      address: '1142 Harlem Rd, Cheektowaga, NY',
      category: 'Plumbing',
      priority: 'High',
      status: 'New',
      scheduledLabel: 'Today 2:30 PM',
      description: 'Tenant reports leaking faucet under kitchen sink.',
    ),
    ContractorJob(
      id: 'J-1002',
      propertyName: 'Elmwood Plaza',
      unitLabel: 'Store 12',
      address: 'Elmwood Ave, Buffalo, NY',
      category: 'Electrical',
      priority: 'Medium',
      status: 'Accepted',
      scheduledLabel: 'Tomorrow 10:00 AM',
      description: 'Replace broken light fixture near entrance.',
    ),
    ContractorJob(
      id: 'J-1003',
      propertyName: 'Lakeview Villas',
      unitLabel: 'Apt 03',
      address: 'Rochester, NY',
      category: 'HVAC',
      priority: 'High',
      status: 'In Progress',
      scheduledLabel: 'Jan 18 3:00 PM',
      description: 'Heater rattling noise; check blower motor + filter.',
    ),
    ContractorJob(
      id: 'J-1004',
      propertyName: 'Harlem Heights',
      unitLabel: 'Apt 1A',
      address: '1142 Harlem Rd, Cheektowaga, NY',
      category: 'Appliance',
      priority: 'Low',
      status: 'Completed',
      scheduledLabel: 'Jan 12',
      description: 'Dishwasher not draining; cleaned filter and tested.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        Row(
          children: [
            Expanded(child: Text('Jobs', style: Theme.of(context).textTheme.titleLarge)),
            FilledButton.tonalIcon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Next: Filters (status, distance, category)')),
              ),
              icon: const Icon(Icons.tune),
              label: const Text('Filter'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...jobs.map((j) => _JobCard(job: j)),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  final ContractorJob job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color badgeBg;
    Color badgeFg;
    if (job.priority == 'High') {
      badgeBg = cs.errorContainer;
      badgeFg = cs.onErrorContainer;
    } else if (job.priority == 'Medium') {
      badgeBg = cs.tertiaryContainer;
      badgeFg = cs.onTertiaryContainer;
    } else {
      badgeBg = cs.secondaryContainer;
      badgeFg = cs.onSecondaryContainer;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ContractorJobDetailScreen(job: job)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text('${job.propertyName} • ${job.unitLabel}', style: Theme.of(context).textTheme.titleMedium),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: badgeBg),
                  child: Text(job.priority, style: TextStyle(color: badgeFg)),
                ),
              ]),
              const SizedBox(height: 8),
              Text(job.address, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  Chip(label: Text(job.category)),
                  const SizedBox(width: 8),
                  Chip(label: Text(job.status)),
                  const Spacer(),
                  Text(job.scheduledLabel, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
