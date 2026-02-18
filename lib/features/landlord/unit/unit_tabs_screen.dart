import 'package:flutter/material.dart';
import 'mock_unit_data.dart';
import 'tabs/rent_board_tab.dart';
import 'tabs/maintenance_inbox_tab.dart';
import 'tabs/contractors_tab.dart';
import 'tabs/documents_tab.dart';
import 'tabs/activity_tab.dart';

class UnitTabsScreen extends StatefulWidget {
  final String propertyId;
  final String unitId;
  final String? propertyName;
  final String? unitName;
  final int initialTab;

  const UnitTabsScreen({
    super.key,
    required this.propertyId,
    required this.unitId,
    this.propertyName,
    this.unitName,
    this.initialTab = 0,
  });

  @override
  State<UnitTabsScreen> createState() => _UnitTabsScreenState();
}

class _UnitTabsScreenState extends State<UnitTabsScreen> with TickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this, initialIndex: widget.initialTab.clamp(0, 5));
}

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bundle = MockUnitData.bundle(
      propertyId: widget.propertyId,
      unitId: widget.unitId,
      propertyName: widget.propertyName,
      unitName: widget.unitName,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${bundle.unitName} • ${bundle.propertyName}'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Rent'),
            Tab(text: 'Maintenance'),
            Tab(text: 'Contractors'),
            Tab(text: 'Documents'),
            Tab(text: 'Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _Overview(bundle: bundle, goToTab: (i) => _tab.animateTo(i)),
          RentBoardTab(bundle: bundle),
          MaintenanceInboxTab(bundle: bundle),
          ContractorsTab(bundle: bundle),
          DocumentsTab(bundle: bundle),
          ActivityTab(bundle: bundle),
        ],
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  final UnitBundle bundle;
  final void Function(int) goToTab;
  const _Overview({required this.bundle, required this.goToTab});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _Card(
          title: 'Unit',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bundle.unitName, style: t.textTheme.titleLarge),
              const SizedBox(height: 6),
              const Text('Type: '),
              const Text('Status: '),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _Metric(label: 'Rent', value: bundle.monthlyRent)),
                  const SizedBox(width: 12),
                  Expanded(child: _Metric(label: 'Balance', value: bundle.currentBalance)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => goToTab(1),
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('View rent'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => goToTab(2),
                      icon: const Icon(Icons.build_outlined),
                      label: const Text('View tickets'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          title: 'Tenant',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bundle.tenantName, style: t.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(bundle.tenantEmail),
              Text(bundle.tenantPhone),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => _openContactTenant(context),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Contact tenant'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).pushNamed(
                        '/landlord/unit/invite',
                        arguments: bundle,
                      ),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Invite'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          title: 'Quick actions',
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add_task_outlined),
                title: const Text('Create maintenance ticket'),
                subtitle: const Text('Log an issue for this unit'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ticket creation will be added soon.')),
                  );
                  goToTab(2);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.upload_file_outlined),
                title: const Text('Upload document'),
                subtitle: const Text('Add lease, receipts, or notices'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Upload will be added soon.')),
                  );
                  goToTab(4);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.mark_email_unread_outlined),
                title: const Text('Pending tenant invites'),
                subtitle: const Text('View property-level invite status'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/landlord/invites/property',
                    arguments: {
                      'propertyId': bundle.propertyId,
                      'propertyName': bundle.propertyName,
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openContactTenant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        final t = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact tenant', style: t.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(bundle.tenantName, style: t.textTheme.bodyLarge),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.call_outlined),
                  title: const Text('Call'),
                  subtitle: Text(bundle.tenantPhone),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling will be enabled soon.')),
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(bundle.tenantEmail),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email will be enabled soon.')),
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.message_outlined),
                  title: const Text('Message'),
                  subtitle: const Text('In-app messaging will be enabled soon.'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Messaging will be enabled soon.')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: t.textTheme.titleMedium),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(value, style: t.textTheme.titleMedium),
        ],
      ),
    );
  }
}
