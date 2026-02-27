import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LandlordSettingsScreen extends ConsumerStatefulWidget {
  const LandlordSettingsScreen({super.key});

  @override
  ConsumerState<LandlordSettingsScreen> createState() =>
      _LandlordSettingsScreenState();
}

class _LandlordSettingsScreenState
    extends ConsumerState<LandlordSettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  bool _autoApproveMinor = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('L-38 • Landlord Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Account',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.person_outlined),
                  title: Text('Name'),
                  trailing: Text('Demo Landlord'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text('Email'),
                  trailing: Text('landlord@ayrnow.demo'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.phone_outlined),
                  title: Text('Phone'),
                  trailing: Text('(555) 123-4567'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Preferences',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  value: _emailNotifications,
                  onChanged: (v) =>
                      setState(() => _emailNotifications = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  value: _pushNotifications,
                  onChanged: (v) =>
                      setState(() => _pushNotifications = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('SMS Notifications'),
                  value: _smsNotifications,
                  onChanged: (v) =>
                      setState(() => _smsNotifications = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Auto-approve minor tickets'),
                  subtitle: const Text('Low priority tickets are auto-approved'),
                  value: _autoApproveMinor,
                  onChanged: (v) =>
                      setState(() => _autoApproveMinor = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Property Management',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.apartment),
                  title: const Text('Manage Properties'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/L-25'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: const Text('Payment Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/L-23F'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out (demo)')),
              );
            },
            icon: Icon(Icons.logout, color: colorScheme.error),
            label: Text(
              'Sign Out',
              style: TextStyle(color: colorScheme.error),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.error),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'AYRNOW v0.2.0+2',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
