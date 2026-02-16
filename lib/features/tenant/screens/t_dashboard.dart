import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/session/tenant_context.dart';
import 'package:ayrnow/features/tenant/screens/t_finance_center.dart';
import 'package:ayrnow/features/tenant/screens/t_models.dart';
import 'package:ayrnow/features/tenant/screens/t_rent_flow.dart';
import 'package:ayrnow/features/tenant/screens/dashboard_summary_cards.dart';
import 'package:ayrnow/features/invite/store/invite_store.dart';
import 'package:ayrnow/ui/shared/widgets/empty_state_widget.dart';
import 'package:ayrnow/features/invite/models/invite_models.dart';

class TenantDashboardScreen extends ConsumerWidget {
  const TenantDashboardScreen({super.key});

  static const _props = <TenantProperty>[
    TenantProperty(
      id: 'p1',
      name: 'Harlem Gardens',
      address: '1142 Harlem Rd, Cheektowaga, NY',
      units: [
        TenantUnit(
            id: 'u1',
            label: 'Apt 2B',
            rentCents: 165000,
            dueDateLabel: 'Due Jan 1',
            isOverdue: true),
        TenantUnit(
            id: 'u2',
            label: 'Apt 3A',
            rentCents: 155000,
            dueDateLabel: 'Due Feb 1',
            isOverdue: false),
      ],
    ),
    TenantProperty(
      id: 'p2',
      name: 'Elmwood Plaza (Commercial)',
      address: 'Elmwood Ave, Buffalo, NY',
      units: [
        TenantUnit(
            id: 'u3',
            label: 'Store 12',
            rentCents: 350000,
            dueDateLabel: 'Due Jan 15',
            isOverdue: false),
        TenantUnit(
            id: 'u4',
            label: 'Store 18',
            rentCents: 420000,
            dueDateLabel: 'Due Jan 15',
            isOverdue: true),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final ctx = ref.watch(tenantContextProvider);
    final activeAccess = ref.watch(
      inviteStoreProvider.select((state) => state.activeAccess),
    );

    final scoped = _resolveScopedPropertyAndUnit(
        _props, ctx.selectedPropertyId, ctx.selectedUnitId);
    final nextProp = scoped.$1;
    final nextUnit = scoped.$2;
    final scopedProps = nextProp != null ? [nextProp] : <TenantProperty>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        Text('Dashboard', style: t.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          'Your unit: rent, maintenance, and community.',
          style: t.textTheme.bodyMedium,
        ),
        const SizedBox(height: 14),
        DashboardSummaryCards(
          nextProperty: nextProp,
          nextUnit: nextUnit,
          maintenanceCount: 0,
          communityUpdatesCount: 0,
        ),
        const SizedBox(height: 14),
        if (nextProp != null && nextUnit != null)
          _UpcomingPaymentCard(property: nextProp, unit: nextUnit)
        else
          const _EmptyPortfolioCard(),
        const SizedBox(height: 14),
        if (activeAccess.isNotEmpty) ...[
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: Text(
                'Access activated for ${activeAccess.first.propertyName} • ${activeAccess.first.unitName}',
              ),
              subtitle: Text('Permission: ${activeAccess.first.permission.label}'),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text('Quick actions', style: t.textTheme.titleMedium),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.card_giftcard_outlined),
            title: const Text('Have an invite code?'),
            subtitle: const Text('Join a property with a code'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => navigateToInviteByCode(context),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Finance'),
            subtitle: const Text('History, receipts, statements'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (nextProp == null) {
                _showSelectUnitDialog(context, ref, _props);
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        TenantFinanceCenterScreen(properties: scopedProps),
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 18),
        Text('Utilities', style: t.textTheme.titleMedium),
        const SizedBox(height: 6),
        Text('Pay utilities here (coming soon).',
            style: t.textTheme.bodyMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _UtilityChip(
              icon: Icons.electric_bolt_outlined,
              label: 'Electric',
              onTap: () => _openComingSoon(context, 'Electric',
                  'Electric bill payments will be supported soon.'),
            ),
            _UtilityChip(
              icon: Icons.water_drop_outlined,
              label: 'Water',
              onTap: () => _openComingSoon(context, 'Water',
                  'Water/sewer bill payments will be supported soon.'),
            ),
            _UtilityChip(
              icon: Icons.local_fire_department_outlined,
              label: 'Gas',
              onTap: () => _openComingSoon(
                  context, 'Gas', 'Gas bill payments will be supported soon.'),
            ),
            _UtilityChip(
              icon: Icons.wifi_outlined,
              label: 'Internet',
              onTap: () => _openComingSoon(context, 'Internet',
                  'Internet bill payments will be supported soon.'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text('My unit', style: t.textTheme.titleMedium),
        const SizedBox(height: 10),
        ...scopedProps.map((p) => _PropertyCard(prop: p)),
      ],
    );
  }

  (TenantProperty?, TenantUnit?) _resolveScopedPropertyAndUnit(
    List<TenantProperty> props,
    String selectedPropertyId,
    String selectedUnitId,
  ) {
    TenantProperty? prop;
    for (final p in props) {
      if (p.id == selectedPropertyId) {
        prop = p;
        break;
      }
    }
    prop ??= props.isNotEmpty ? props.first : null;
    if (prop == null || prop.units.isEmpty) return (prop, null);
    TenantUnit? unit;
    if (selectedUnitId.isNotEmpty) {
      for (final u in prop.units) {
        if (u.id == selectedUnitId) {
          unit = u;
          break;
        }
      }
    }
    unit ??= prop.units.first;
    return (prop, unit);
  }
}

class _UpcomingPaymentCard extends StatelessWidget {
  final TenantProperty property;
  final TenantUnit unit;

  const _UpcomingPaymentCard({required this.property, required this.unit});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upcoming payment', style: t.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('${property.name} • ${unit.label}',
                      style: t.textTheme.bodyLarge),
                ),
                Chip(
                  label: Text(unit.isOverdue ? 'Overdue' : 'Due'),
                  backgroundColor: unit.isOverdue
                      ? cs.errorContainer
                      : cs.secondaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${money(unit.rentCents)} • ${unit.dueDateLabel}',
                style: t.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TenantPayRentScreen(
                              property: property, unit: unit),
                        ),
                      );
                    },
                    icon: const Icon(Icons.payments_outlined),
                    label: Text(unit.isOverdue ? 'Pay now' : 'Pay'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              TenantPropertyUnitsScreen(property: property),
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Ledger'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPortfolioCard extends StatelessWidget {
  const _EmptyPortfolioCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No rentals yet', style: t.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Once you are added to a property, your rent and statements will appear here.',
              style: t.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final TenantProperty prop;
  const _PropertyCard({required this.prop});

  @override
  Widget build(BuildContext context) {
    final overdueCount = prop.units.where((u) => u.isOverdue).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => TenantPropertyUnitsScreen(property: prop)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.apartment_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(prop.name,
                          style: Theme.of(context).textTheme.titleMedium)),
                  if (overdueCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Theme.of(context).colorScheme.errorContainer,
                      ),
                      child: Text(
                        '$overdueCount overdue',
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(prop.address, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('${prop.units.length} units',
                      style: Theme.of(context).textTheme.labelLarge),
                  const Spacer(),
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

class _UtilityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UtilityChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

void _showSelectUnitDialog(
  BuildContext context,
  WidgetRef ref,
  List<TenantProperty> props,
) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      content: EmptyStateWidget(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Select your unit',
        subtitle:
            'Choose a property and unit to view rent and finance.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            _showPropertyUnitSheet(
              context,
              ref.read(tenantContextProvider.notifier),
              props,
            );
          },
          child: const Text('Select now'),
        ),
      ],
    ),
  );
}

void _showPropertyUnitSheet(
  BuildContext context,
  TenantContextNotifier notifier,
  List<TenantProperty> props,
) {
  showModalBottomSheet(
    context: context,
    builder: (sheetContext) => ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        ...props.expand((prop) => [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  prop.name,
                  style: Theme.of(sheetContext).textTheme.titleSmall,
                ),
              ),
              ...prop.units.map(
                (unit) => ListTile(
                  title: Text(unit.label),
                  subtitle: Text(prop.name),
                  onTap: () {
                    notifier.selectProperty(prop.id);
                    notifier.selectUnit(unit.id);
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Selection saved')),
                    );
                  },
                ),
              ),
            ]),
      ],
    ),
  );
}

void _openComingSoon(BuildContext context, String title, String body) {
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
            Text(title, style: t.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body, style: t.textTheme.bodyMedium),
            const SizedBox(height: 14),
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
