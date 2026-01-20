import 'package:flutter/material.dart';
import 't_models.dart';
import 't_rent_flow.dart';

/// Finance Center = History + Statements (combined).
/// Backend-ready: later hydrate from ledger/receipts/statements APIs.
class TenantFinanceCenterScreen extends StatelessWidget {
  final List<TenantProperty> properties;
  const TenantFinanceCenterScreen({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finance'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Activity'),
              Tab(text: 'Statements'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ActivityTab(properties: properties),
            _StatementsTab(properties: properties),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem {
  final TenantProperty property;
  final TenantUnit unit;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPaid;

  const _ActivityItem({
    required this.property,
    required this.unit,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPaid,
  });
}

class _ActivityTab extends StatelessWidget {
  final List<TenantProperty> properties;
  const _ActivityTab({required this.properties});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    final items = <_ActivityItem>[];
    for (final p in properties) {
      for (final u in p.units) {
        items.add(
          _ActivityItem(
            property: p,
            unit: u,
            title: u.isOverdue ? 'Payment overdue' : 'Upcoming payment',
            subtitle:
                '${p.name} • ${u.label} • ${money(u.rentCents)} • ${u.dueDateLabel}',
            icon: u.isOverdue
                ? Icons.warning_amber_outlined
                : Icons.schedule_outlined,
            isPaid: false,
          ),
        );
        items.add(
          _ActivityItem(
            property: p,
            unit: u,
            title: 'Last payment recorded',
            subtitle:
                '${p.name} • ${u.label} • ${money(u.rentCents)} • Paid (mock)',
            icon: Icons.check_circle_outline,
            isPaid: true,
          ),
        );
      }
    }

    int rank(_ActivityItem it) => it.isPaid ? 2 : (it.unit.isOverdue ? 0 : 1);
    items.sort((a, b) => rank(a).compareTo(rank(b)));

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined, size: 44),
              const SizedBox(height: 10),
              Text('No activity yet', style: t.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                'Once payments are made, you will see receipts and statements here.',
                textAlign: TextAlign.center,
                style: t.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final it = items[i];

        return Card(
          child: ListTile(
            leading: Icon(it.icon),
            title: Text(it.title),
            subtitle: Text(it.subtitle),
            trailing: it.isPaid
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'View',
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () {
                          // For now: deep-link to unit details (ledger path).
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TenantPropertyUnitsScreen(
                                  property: it.property),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Download (coming soon)',
                        icon: const Icon(Icons.download_outlined),
                        onPressed: () => _soon(context, 'Download'),
                      ),
                      IconButton(
                        tooltip: 'Share (coming soon)',
                        icon: const Icon(Icons.ios_share_outlined),
                        onPressed: () => _soon(context, 'Share'),
                      ),
                    ],
                  )
                : IconButton(
                    tooltip: 'Pay / Open',
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TenantPayRentScreen(
                              property: it.property, unit: it.unit),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  void _soon(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what is coming soon.')),
    );
  }
}

class _StatementItem {
  final String monthLabel;
  final int totalCents;
  final int unitCount;

  const _StatementItem({
    required this.monthLabel,
    required this.totalCents,
    required this.unitCount,
  });
}

class _StatementsTab extends StatelessWidget {
  final List<TenantProperty> properties;
  const _StatementsTab({required this.properties});

  @override
  Widget build(BuildContext context) {
    final allUnits = <TenantUnit>[];
    for (final p in properties) {
      allUnits.addAll(p.units);
    }

    final statements = <_StatementItem>[
      _StatementItem(
        monthLabel: 'This month (mock)',
        totalCents: allUnits.fold<int>(0, (s, u) => s + u.rentCents),
        unitCount: allUnits.length,
      ),
      _StatementItem(
        monthLabel: 'Last month (mock)',
        totalCents: allUnits.fold<int>(0, (s, u) => s + u.rentCents),
        unitCount: allUnits.length,
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: statements.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final s = statements[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(s.monthLabel),
            subtitle:
                Text('Total: ${money(s.totalCents)} • ${s.unitCount} unit(s)'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'View',
                  icon: const Icon(Icons.visibility_outlined),
                  onPressed: () => _soon(context, 'Statement view'),
                ),
                IconButton(
                  tooltip: 'Download (coming soon)',
                  icon: const Icon(Icons.download_outlined),
                  onPressed: () => _soon(context, 'Download'),
                ),
                IconButton(
                  tooltip: 'Share (coming soon)',
                  icon: const Icon(Icons.ios_share_outlined),
                  onPressed: () => _soon(context, 'Share'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _soon(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what is coming soon.')),
    );
  }
}
