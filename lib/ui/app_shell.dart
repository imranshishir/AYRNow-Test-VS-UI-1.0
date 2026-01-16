import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/state/providers.dart';
import '../core/models/role.dart';
import '../features/landlord/l12_dashboard.dart';
import '../features/tenant/t06_dashboard.dart';
import '../features/contractor/c10_jobs_feed.dart';
import '../features/guard/s10_approvals_queue.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final tabTitle = _tabTitle(index);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            Image.asset(
              'assets/logo/ayrnow_logo.png',
              height: 28,
              errorBuilder: (_, __, ___) => const Icon(Icons.home_work_outlined),
            ),
            const SizedBox(width: 10),
            Text(tabTitle),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/I-10'),
            icon: const Icon(Icons.notifications_none_outlined),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: _buildBodyForRole(user.role, index),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), label: 'Pay'),
          NavigationDestination(icon: Icon(Icons.build_outlined), label: 'Tickets'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, _fabRouteForRole(user.role)),
        icon: const Icon(Icons.add),
        label: Text(_fabLabelForRole(user.role)),
      ),
    );
  }

  String _tabTitle(int i) {
    switch (i) {
      case 0:
        return 'AYRNOW';
      case 1:
        return 'Payments';
      case 2:
        return 'Maintenance';
      default:
        return 'Profile';
    }
  }

  String _fabLabelForRole(UserRole role) {
    switch (role) {
      case UserRole.tenant:
        return 'Pay';
      case UserRole.landlord:
  case UserRole.investor:
  case UserRole.admin:
  case UserRole.investor:
  case UserRole.admin:
  case UserRole.investor:
  case UserRole.admin:
      case UserRole.investor:
        return 'New Ticket';
      case UserRole.contractor:
        return 'New Bid';
      case UserRole.guard:
        return 'Approve';
    }
  }

  String _fabRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.tenant:
        return '/T-10';
      case UserRole.landlord:
  case UserRole.investor:
  case UserRole.admin:
  case UserRole.investor:
  case UserRole.admin:
  case UserRole.investor:
  case UserRole.admin:
      case UserRole.investor:
        return '/L-30';
      case UserRole.contractor:
        return '/C-10';
      case UserRole.guard:
        return '/S-10';
    }
  }

  Widget _buildBodyForRole(UserRole role, int tab) {
    // Keep it simple: Home shows the role dashboard; other tabs route to existing screens or placeholders.
    if (tab == 0) {
      switch (role) {
        case UserRole.tenant:
          return const TenantDashboardScreen();
        case UserRole.landlord:
  case UserRole.investor:
  case UserRole.admin:
  case UserRole.investor:
  case UserRole.admin:
  case UserRole.investor:
  case UserRole.admin:
        case UserRole.investor:
          return const LandlordDashboardScreen();
        case UserRole.contractor:
          return const ContractorJobsFeedScreen();
        case UserRole.guard:
          return const GuardApprovalsQueueScreen();
      }
    }

    if (tab == 1) {
      return _QuickLinks(
        title: 'Payments',
        items: [
          _QuickLink('Pay rent', Icons.payments_outlined, '/T-10'),
          _QuickLink('Receipts', Icons.receipt_long_outlined, '/T-14'),
          _QuickLink('Rent board', Icons.table_chart_outlined, '/L-23'),
        ],
      );
    }

    if (tab == 2) {
      return _QuickLinks(
        title: 'Maintenance',
        items: [
          _QuickLink('Maintenance inbox', Icons.build_outlined, '/L-30'),
          _QuickLink('Create ticket', Icons.add_task_outlined, '/T-20'),
        ],
      );
    }

    return _QuickLinks(
      title: 'Profile',
      items: [
        _QuickLink('Switch role', Icons.swap_horiz_outlined, '/'),
        _QuickLink('Settings', Icons.settings_outlined, '/A-20'),
      ],
    );
  }
}

class _QuickLinks extends StatelessWidget {
  final String title;
  final List<_QuickLink> items;

  const _QuickLinks({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        for (final item in items)
          Card(
            child: ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, item.route),
            ),
          ),
      ],
    );
  }
}

class _QuickLink {
  final String label;
  final IconData icon;
  final String route;
  const _QuickLink(this.label, this.icon, this.route);
}
