import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/role.dart';
import '../../core/state/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final initials = user.name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              child: Text(initials, style: theme.textTheme.headlineMedium),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(user.name, style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${user.id}@ayrnow.com',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              avatar: const Icon(Icons.badge_outlined, size: 18),
              label: Text(user.role.label),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile (coming soon)')),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profile'),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('Member since', 'Jan 2024'),
                  _stat(_roleStatLabel(user.role), _roleStatValue(user.role)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Account Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/A-20'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/help'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About AYRNOW'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('AYRNOW v0.2.0 — Phase-2 MVP')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
            icon: const Icon(Icons.swap_horiz_outlined),
            label: const Text('Switch Role'),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  String _roleStatLabel(UserRole role) {
    switch (role) {
      case UserRole.landlord:
        return 'Properties';
      case UserRole.tenant:
        return 'Lease months';
      case UserRole.contractor:
        return 'Jobs done';
      case UserRole.guard:
        return 'Shifts';
      case UserRole.investor:
        return 'Investments';
      case UserRole.admin:
        return 'Users managed';
    }
  }

  String _roleStatValue(UserRole role) {
    switch (role) {
      case UserRole.landlord:
        return '3';
      case UserRole.tenant:
        return '14';
      case UserRole.contractor:
        return '27';
      case UserRole.guard:
        return '180';
      case UserRole.investor:
        return '5';
      case UserRole.admin:
        return '42';
    }
  }
}
