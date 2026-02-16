import 'package:flutter/material.dart';
import 'package:ayrnow/features/guard/screens/guard_demo_data.dart';
import 'package:ayrnow/features/guard/screens/guard_approvals_queue_screen.dart';
import 'package:ayrnow/features/guard/screens/guard_active_visitors_screen.dart';
import 'package:ayrnow/features/guard/screens/guard_incident_report_screen.dart';

/// Guard "home" is rendered inside HomeShell.body.
/// HomeShell already provides the top AppBar + Switch Role menu.
/// Here we provide a real, navigable guard workspace with HIFI skeleton screens.
class GuardHome extends StatefulWidget {
  const GuardHome({super.key});

  @override
  State<GuardHome> createState() => _GuardHomeState();
}

class _GuardHomeState extends State<GuardHome> {
  final GuardDemoStore _store = GuardDemoStore();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      children: [
        _header(context),
        const SizedBox(height: 12),

        // Quick actions row (feels like a real ops console)
        Row(
          children: [
            Expanded(
              child: _actionCard(
                context,
                icon: Icons.approval_outlined,
                title: 'Approvals',
                subtitle: 'Verify + check-in visitors',
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            GuardApprovalsQueueScreen(store: _store)),
                  );
                  setState(() {});
                },
                badge: _store.approvals.length,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                context,
                icon: Icons.people_outline,
                title: 'Active',
                subtitle: 'Who is inside now',
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            GuardActiveVisitorsScreen(store: _store)),
                  );
                  setState(() {});
                },
                badge: _store.active.length,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _actionCard(
          context,
          icon: Icons.report_outlined,
          title: 'Incident Reports',
          subtitle: 'Create + view report history',
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => GuardIncidentReportScreen(store: _store)),
            );
            setState(() {});
          },
        ),

        const SizedBox(height: 16),
        _sectionTitle(context, 'Today at a glance'),
        const SizedBox(height: 10),

        // Simple dashboard cards
        Row(
          children: [
            Expanded(
                child: _statTile(context, 'Pending approvals',
                    '${_store.approvals.length}', Icons.inbox_outlined)),
            const SizedBox(width: 12),
            Expanded(
                child: _statTile(context, 'Active visitors',
                    '${_store.active.length}', Icons.badge_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        _statTile(
          context,
          'Incidents logged',
          '${_store.incidents.length}',
          Icons.security_outlined,
          wide: true,
        ),

        const SizedBox(height: 18),
        _sectionTitle(context, 'How to use (demo)'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '1) Open Approvals → Verify & Check-in a visitor.\n'
              '2) Visitor will appear in Active Visitors.\n'
              '3) Check-out when they exit.\n'
              '4) Create Incident Reports anytime.\n\n'
              'You can always go back using the Back button, and switch roles from the top-right menu.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Icon(Icons.shield_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Security Desk',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    'Approvals, entry logs, incidents',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String t) {
    return Text(t, style: Theme.of(context).textTheme.titleSmall);
  }

  Widget _statTile(
      BuildContext context, String label, String value, IconData icon,
      {bool wide = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(value, style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int? badge,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(title,
                                style: Theme.of(context).textTheme.titleSmall)),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                            ),
                            child: Text(
                              '$badge',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
