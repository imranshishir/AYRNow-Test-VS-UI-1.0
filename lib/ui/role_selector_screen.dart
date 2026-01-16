import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/state/providers.dart';
import '../core/models/role.dart';
import '../core/models/user.dart';

class RoleSelectorScreen extends ConsumerWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            const Text('AYRNOW'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Welcome 👋', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Pick a role to explore the Phase‑2 demo.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          _roleCard(context, ref, UserRole.tenant, 'Pay rent, tickets, receipts', '/home'),
          _roleCard(context, ref, UserRole.landlord, 'Rent board, maintenance inbox', '/home'),
          _roleCard(context, ref, UserRole.contractor, 'Jobs feed, bids, payouts', '/home'),
          _roleCard(context, ref, UserRole.guard, 'Guest approvals and logs', '/home'),

          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('View all screens (spec)'),
              subtitle: const Text('Jump to any screen by ID'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/spec'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleCard(
    BuildContext context,
    WidgetRef ref,
    UserRole role,
    String subtitle,
    String route,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(_roleIcon(role)),
        title: Text(role.label),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ref.read(currentUserProvider.notifier).state =
              AppUser(id: 'demo', name: 'Demo ${role.label}', role: role);
          Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.tenant:
        return Icons.person_outline;
      case UserRole.landlord:
        case UserRole.investor:
        case UserRole.admin:
      case UserRole.investor:
        return Icons.home_outlined;
      case UserRole.contractor:
        return Icons.handyman_outlined;
      case UserRole.guard:
        return Icons.security_outlined;
    }
  }
}
