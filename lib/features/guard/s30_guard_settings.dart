import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuardSettingsScreen extends ConsumerStatefulWidget {
  const GuardSettingsScreen({super.key});

  @override
  ConsumerState<GuardSettingsScreen> createState() =>
      _GuardSettingsScreenState();
}

class _GuardSettingsScreenState extends ConsumerState<GuardSettingsScreen> {
  bool _autoApprove = false;
  bool _soundAlerts = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('S-30 • Guard Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Shift Information', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.wb_sunny),
                  title: Text('Current Shift'),
                  subtitle: Text('Morning (6 AM - 2 PM)'),
                ),
                ListTile(
                  leading: Icon(Icons.nights_stay),
                  title: Text('Next Shift'),
                  subtitle: Text('Evening (2 PM - 10 PM)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Preferences', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Auto-approve known visitors'),
            subtitle:
                const Text('Automatically approve returning visitors'),
            value: _autoApprove,
            onChanged: (v) => setState(() => _autoApprove = v),
          ),
          SwitchListTile(
            title: const Text('Sound alerts'),
            subtitle: const Text('Play sound for new approval requests'),
            value: _soundAlerts,
            onChanged: (v) => setState(() => _soundAlerts = v),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Notification preferences (demo).')),
              );
            },
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.emergency),
            title: const Text('Emergency Contacts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Emergency contacts (demo).')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Report Issue'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report issue (demo).')),
              );
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out (demo).')),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'AYRNOW v0.2.0+2',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
