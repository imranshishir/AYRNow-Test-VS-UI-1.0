import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/screens/landlord_demo_store.dart';
import 'package:ayrnow/features/landlord/screens/landlord_rent_screen.dart';
import 'package:ayrnow/features/landlord/screens/landlord_maintenance_screen.dart';
import 'package:ayrnow/features/landlord/screens/landlord_contractors_screen.dart';

/// ------------------------------
/// Demo Models + Data (Landlord)
/// ------------------------------
enum PropertyType { residential, commercial, land }

extension PropertyTypeX on PropertyType {
  String get label => switch (this) {
        PropertyType.residential => 'Residential',
        PropertyType.commercial => 'Commercial',
        PropertyType.land => 'Land',
      };
}

class DemoTenant {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String leaseStart;
  final String leaseEnd;
  final double monthlyRent;
  final double deposit;
  const DemoTenant({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.leaseStart,
    required this.leaseEnd,
    required this.monthlyRent,
    required this.deposit,
  });
}

class DemoUnit {
  final String id; // e.g. "A-101", "Store-12"
  final String label; // e.g. "Apt 101", "Store 12"
  final String status; // occupied / vacant
  final DemoTenant? tenant;
  final double monthlyRent;
  const DemoUnit({
    required this.id,
    required this.label,
    required this.status,
    required this.monthlyRent,
    this.tenant,
  });
}

class DemoProperty {
  final String id;
  final String name;
  final PropertyType type;
  final String address;
  final List<DemoUnit> units;
  const DemoProperty({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.units,
  });

  int get occupiedCount => units.where((u) => u.status == 'occupied').length;
  int get vacantCount => units.where((u) => u.status != 'occupied').length;
}

final List<DemoProperty> demoProperties = [
  DemoProperty(
    id: 'P-1001',
    name: 'Elm Street Apartments',
    type: PropertyType.residential,
    address: '1142 Harlem Rd, Cheektowaga, NY',
    units: [
      DemoUnit(
        id: 'A-101',
        label: 'Apt 101',
        status: 'occupied',
        monthlyRent: 1450,
        tenant: DemoTenant(
          id: 'T-501',
          name: 'Sarah Johnson',
          phone: '(716) 555-1201',
          email: 'sarah.johnson@email.com',
          leaseStart: '2025-06-01',
          leaseEnd: '2026-05-31',
          monthlyRent: 1450,
          deposit: 1450,
        ),
      ),
      const DemoUnit(
          id: 'A-102', label: 'Apt 102', status: 'vacant', monthlyRent: 1500),
      DemoUnit(
        id: 'A-103',
        label: 'Apt 103',
        status: 'occupied',
        monthlyRent: 1525,
        tenant: const DemoTenant(
          id: 'T-502',
          name: 'David Kim',
          phone: '(716) 555-3312',
          email: 'david.kim@email.com',
          leaseStart: '2025-09-01',
          leaseEnd: '2026-08-31',
          monthlyRent: 1525,
          deposit: 1525,
        ),
      ),
    ],
  ),
  DemoProperty(
    id: 'P-2001',
    name: 'Riverside Plaza',
    type: PropertyType.commercial,
    address: '200 Main St, Buffalo, NY',
    units: [
      DemoUnit(
        id: 'S-01',
        label: 'Store 01',
        status: 'occupied',
        monthlyRent: 3200,
        tenant: const DemoTenant(
          id: 'T-601',
          name: 'Corner Mart LLC',
          phone: '(716) 555-8811',
          email: 'ops@cornermart.com',
          leaseStart: '2024-01-01',
          leaseEnd: '2027-12-31',
          monthlyRent: 3200,
          deposit: 6400,
        ),
      ),
      const DemoUnit(
          id: 'S-02', label: 'Store 02', status: 'vacant', monthlyRent: 3500),
      DemoUnit(
        id: 'S-03',
        label: 'Store 03',
        status: 'occupied',
        monthlyRent: 4100,
        tenant: const DemoTenant(
          id: 'T-602',
          name: 'Nail Studio Inc',
          phone: '(716) 555-9922',
          email: 'hello@nailstudio.com',
          leaseStart: '2025-03-01',
          leaseEnd: '2028-02-28',
          monthlyRent: 4100,
          deposit: 8200,
        ),
      ),
    ],
  ),
];

/// ------------------------------
/// Landlord Flow Screens
/// Dashboard → Properties → Property → Units → Unit → Tenant
/// ------------------------------

class LandlordDashboardScreen extends StatefulWidget {
  const LandlordDashboardScreen({super.key});

  State<LandlordDashboardScreen> createState() =>
      _LandlordDashboardScreenState();
}

class _LandlordDashboardScreenState extends State<LandlordDashboardScreen> {
  final LandlordDemoStore _store = LandlordDemoStore();

  @override
  Widget build(BuildContext context) {
    final totalProps = demoProperties.length;
    final totalUnits =
        demoProperties.fold<int>(0, (p, e) => p + e.units.length);
    final occupied = demoProperties.fold<int>(0, (p, e) => p + e.occupiedCount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _SummaryHeader(
          title: 'Landlord Dashboard',
          subtitle: 'Manage properties, units, tenants, rent, and maintenance.',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
                child: _MetricCard(label: 'Properties', value: '$totalProps')),
            const SizedBox(width: 12),
            Expanded(child: _MetricCard(label: 'Units', value: '$totalUnits')),
            const SizedBox(width: 12),
            Expanded(child: _MetricCard(label: 'Occupied', value: '$occupied')),
          ],
        ),
        const SizedBox(height: 16),
        _ActionTile(
          icon: Icons.apartment_rounded,
          title: 'Properties',
          subtitle: 'View/add properties → drill down to units → tenants',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LandlordPropertiesScreen()),
          ),
        ),
        _ActionTile(
          icon: Icons.payments_rounded,
          title: 'Rent (coming next)',
          subtitle: 'Ledger, reminders, receipts, monthly summary',
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => LandlordRentScreen(store: _store))),
        ),
        _ActionTile(
          icon: Icons.build_rounded,
          title: 'Maintenance (coming next)',
          subtitle: 'Ticket inbox, assign contractor, approve completion',
          onTap: () =>
              _toast(context, 'Next step: Maintenance tickets screens'),
        ),
        _ActionTile(
          icon: Icons.handyman_rounded,
          title: 'Contractors (coming next)',
          subtitle: 'Directory, work orders, invoices',
          onTap: () =>
              _toast(context, 'Next step: Contractor assignment screens'),
        ),
      ],
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class LandlordPropertiesScreen extends StatefulWidget {
  const LandlordPropertiesScreen({super.key});

  @override
  State<LandlordPropertiesScreen> createState() =>
      _LandlordPropertiesScreenState();
}

class _LandlordPropertiesScreenState extends State<LandlordPropertiesScreen> {
  final _q = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = demoProperties.where((p) {
      final hay = '${p.name} ${p.address} ${p.type.label}'.toLowerCase();
      return hay.contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        actions: [
          IconButton(
            tooltip: 'Add property',
            onPressed: () => _showAddPropertySheet(context),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          TextField(
            controller: _q,
            decoration: InputDecoration(
              hintText: 'Search properties…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _q.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          ...filtered.map((p) => _PropertyCard(
                p: p,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) =>
                          LandlordPropertyDetailScreen(property: p)),
                ),
              )),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Text(
                  'No properties found.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddPropertySheet(BuildContext context) {
    final name = TextEditingController();
    final addr = TextEditingController();
    PropertyType type = PropertyType.residential;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Property',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                  controller: name,
                  decoration:
                      const InputDecoration(labelText: 'Property name')),
              const SizedBox(height: 10),
              TextField(
                  controller: addr,
                  decoration: const InputDecoration(labelText: 'Address')),
              const SizedBox(height: 10),
              DropdownButtonFormField<PropertyType>(
                value: type,
                items: PropertyType.values
                    .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.label)))
                    .toList(),
                onChanged: (v) => type = v ?? PropertyType.residential,
                decoration: const InputDecoration(labelText: 'Property type'),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Demo: Add Property saved (wire it to state later)')),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Save'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class LandlordPropertyDetailScreen extends StatelessWidget {
  final DemoProperty property;
  const LandlordPropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final occupied = property.occupiedCount;
    final vacant = property.vacantCount;

    return Scaffold(
      appBar: AppBar(title: Text(property.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _SummaryHeader(
            title: property.name,
            subtitle: '${property.type.label} • ${property.address}',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _MetricCard(
                      label: 'Units', value: '${property.units.length}')),
              const SizedBox(width: 12),
              Expanded(
                  child: _MetricCard(label: 'Occupied', value: '$occupied')),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(label: 'Vacant', value: '$vacant')),
            ],
          ),
          const SizedBox(height: 18),
          Text('Units', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...property.units.map((u) => _UnitTile(
                unit: u,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => LandlordUnitDetailScreen(
                          property: property, unit: u)),
                ),
              )),
        ],
      ),
    );
  }
}

class LandlordUnitDetailScreen extends StatelessWidget {
  final DemoProperty property;
  final DemoUnit unit;
  const LandlordUnitDetailScreen(
      {super.key, required this.property, required this.unit});

  @override
  Widget build(BuildContext context) {
    final tenant = unit.tenant;

    return Scaffold(
      appBar: AppBar(title: Text('${property.name} • ${unit.label}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _SummaryHeader(
            title: unit.label,
            subtitle:
                '${unit.status.toUpperCase()} • \$${unit.monthlyRent.toStringAsFixed(0)}/mo',
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Tenant',
            child: tenant == null
                ? Row(
                    children: [
                      const Icon(Icons.person_outline),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('No tenant (vacant).')),
                      TextButton(
                        onPressed: () =>
                            _toast(context, 'Next: Add/Invite Tenant flow'),
                        child: const Text('Add tenant'),
                      ),
                    ],
                  )
                : ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(tenant.name),
                    subtitle: Text('${tenant.email}\n${tenant.phone}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => LandlordTenantDetailScreen(
                              property: property, unit: unit, tenant: tenant)),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Rent Ledger (skeleton)',
            child: Column(
              children: [
                _LedgerRow(
                    month: 'Jan 2026', status: 'Due', amount: unit.monthlyRent),
                _LedgerRow(
                    month: 'Dec 2025',
                    status: 'Paid',
                    amount: unit.monthlyRent),
                _LedgerRow(
                    month: 'Nov 2025',
                    status: 'Paid',
                    amount: unit.monthlyRent),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toast(context, 'Next: Send reminder'),
                        icon: const Icon(Icons.notifications_none),
                        label: const Text('Send reminder'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            _toast(context, 'Next: Mark paid / receipt'),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Mark paid'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Maintenance Tickets (skeleton)',
            child: Column(
              children: [
                _TicketRow(title: 'Leaking faucet', status: 'Open', age: '2d'),
                _TicketRow(
                    title: 'AC not cooling', status: 'In progress', age: '5d'),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _toast(context, 'Next: Create ticket'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create ticket'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class LandlordTenantDetailScreen extends StatelessWidget {
  final DemoProperty property;
  final DemoUnit unit;
  final DemoTenant tenant;
  const LandlordTenantDetailScreen({
    super.key,
    required this.property,
    required this.unit,
    required this.tenant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tenant • ${tenant.name}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _SummaryHeader(
            title: tenant.name,
            subtitle: '${property.name} • ${unit.label}',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.email_outlined,
            label: 'Email',
            value: tenant.email,
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _toast(context, 'Copied (demo)'),
            ),
          ),
          _InfoCard(
              icon: Icons.phone_outlined, label: 'Phone', value: tenant.phone),
          _InfoCard(
              icon: Icons.calendar_month_outlined,
              label: 'Lease',
              value: '${tenant.leaseStart} → ${tenant.leaseEnd}'),
          _InfoCard(
              icon: Icons.payments_outlined,
              label: 'Monthly Rent',
              value: '\$${tenant.monthlyRent.toStringAsFixed(0)}'),
          _InfoCard(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Deposit',
              value: '\$${tenant.deposit.toStringAsFixed(0)}'),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Quick actions (skeleton)',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _toast(context, 'Next: Message tenant'),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Message'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () =>
                            _toast(context, 'Next: Send rent notice'),
                        icon: const Icon(Icons.notifications_none),
                        label: const Text('Notice'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _toast(context, 'Next: Move-out workflow'),
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Move-out / Close lease'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// ------------------------------
/// UI building blocks
/// ------------------------------
class _SummaryHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SummaryHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final DemoProperty p;
  final VoidCallback onTap;
  const _PropertyCard({required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(p.name,
                          style: Theme.of(context).textTheme.titleMedium)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Text(p.type.label,
                        style: Theme.of(context).textTheme.labelMedium),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(p.address, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Pill(
                      icon: Icons.home_work_outlined,
                      text: '${p.units.length} units'),
                  const SizedBox(width: 10),
                  _Pill(
                      icon: Icons.check_circle_outline,
                      text: '${p.occupiedCount} occupied'),
                  const SizedBox(width: 10),
                  _Pill(
                      icon: Icons.circle_outlined,
                      text: '${p.vacantCount} vacant'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  final DemoUnit unit;
  final VoidCallback onTap;
  const _UnitTile({required this.unit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOccupied = unit.status == 'occupied';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(isOccupied ? Icons.person : Icons.meeting_room_outlined),
        ),
        title: Text(unit.label),
        subtitle: Text(
            '${unit.status.toUpperCase()} • \$${unit.monthlyRent.toStringAsFixed(0)}/mo'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  final String month;
  final String status;
  final double amount;
  const _LedgerRow(
      {required this.month, required this.status, required this.amount});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final badgeColor =
        status == 'Paid' ? cs.primaryContainer : cs.tertiaryContainer;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(.25)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(month)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999), color: badgeColor),
            child: Text(status, style: Theme.of(context).textTheme.labelMedium),
          ),
          const SizedBox(width: 10),
          Text('\$${amount.toStringAsFixed(0)}'),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final String title;
  final String status;
  final String age;
  const _TicketRow(
      {required this.title, required this.status, required this.age});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_num_outlined, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(age),
          const SizedBox(width: 10),
          Text(status, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  const _InfoCard(
      {required this.icon,
      required this.label,
      required this.value,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
        trailing: trailing,
      ),
    );
  }
}
