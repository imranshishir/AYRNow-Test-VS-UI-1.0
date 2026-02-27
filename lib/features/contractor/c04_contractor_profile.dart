import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContractorProfileScreen extends ConsumerWidget {
  const ContractorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('C-04 • Contractor Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      'MP',
                      style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text("Mike's Plumbing",
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text('4.8', style: theme.textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text('47',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          Text('Jobs completed',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Jan 2024',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          Text('Member since',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Skills & Services', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(label: Text('Plumbing')),
              Chip(label: Text('HVAC')),
              Chip(label: Text('General Repairs')),
            ],
          ),
          const SizedBox(height: 16),
          Text('Service Area', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text('Within 10 miles of downtown'),
          const SizedBox(height: 16),
          Text('Certifications', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Icons.verified),
            title: Text('Licensed Plumber - State #12345'),
          ),
          const ListTile(
            leading: Icon(Icons.shield),
            title: Text('Insured - \$1M coverage'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile (demo).')),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/C-40'),
          ),
        ],
      ),
    );
  }
}
