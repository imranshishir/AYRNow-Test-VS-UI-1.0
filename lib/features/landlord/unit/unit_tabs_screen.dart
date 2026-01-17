import 'package:flutter/material.dart';
import 'mock_unit_data.dart';
import 'tabs/rent_board_tab.dart';
import 'tabs/maintenance_inbox_tab.dart';
import 'tabs/contractors_tab.dart';

class UnitTabsScreen extends StatefulWidget {
  final String propertyId;
  final String unitId;

  const UnitTabsScreen({
    super.key,
    required this.propertyId,
    required this.unitId,
  });

  @override
  State<UnitTabsScreen> createState() => _UnitTabsScreenState();
}

class _UnitTabsScreenState extends State<UnitTabsScreen> with TickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bundle = MockUnitData.bundle(propertyId: widget.propertyId, unitId: widget.unitId);

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
              Text('Type: ${bundle.unitType}'),
              Text('Status: ${bundle.occupancyStatus}'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _Metric(label: 'Rent', value: bundle.monthlyRent)),
                  const SizedBox(width: 12),
                  Expanded(child: _Metric(label: 'Balance', value: bundle.currentBalance)),
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
              FilledButton.tonalIcon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demo: message tenant')),
                  );
                },
                icon: const Icon(Icons.message_outlined),
                label: const Text('Message tenant'),
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
                leading: const Icon(Icons.attach_money),
                title: const Text('Go to Rent Board'),
                subtitle: const Text('Ledger, collections, receipts'),
                onTap: () => goToTab(1),
              ),
              ListTile(
                leading: const Icon(Icons.build_outlined),
                title: const Text('Go to Maintenance'),
                subtitle: const Text('Tickets, assignments, status updates'),
                onTap: () => goToTab(2),
              ),
              ListTile(
                leading: const Icon(Icons.handyman_outlined),
                title: const Text('Go to Contractors'),
                subtitle: const Text('Assign, view history'),
                onTap: () => goToTab(3),
              ),
            ],
          ),
        ),
      ],
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
