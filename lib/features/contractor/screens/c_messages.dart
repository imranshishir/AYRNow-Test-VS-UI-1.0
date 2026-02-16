import 'package:flutter/material.dart';

class ContractorMessagesScreen extends StatelessWidget {
  const ContractorMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        Text('Messages', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text('Job chats and landlord/tenant communications (HIFI skeleton).',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.apartment)),
            title: const Text('Harlem Heights • Apt 2B'),
            subtitle: const Text('Landlord: Please prioritize this leak today.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Next: Chat thread screen')),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.storefront)),
            title: const Text('Elmwood Plaza • Store 12'),
            subtitle: const Text('Tenant: Light keeps flickering.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Next: Chat thread screen')),
            ),
          ),
        ),
      ],
    );
  }
}
