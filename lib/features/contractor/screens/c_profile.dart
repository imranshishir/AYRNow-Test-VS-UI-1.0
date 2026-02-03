import 'package:flutter/material.dart';

class ContractorProfileScreen extends StatelessWidget {
  const ContractorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        Text('Profile', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const CircleAvatar(child: Icon(Icons.handyman)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Demo Contractor', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text('contractor@ayrnow.com', style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  )
                ]),
                const SizedBox(height: 12),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('Verification (next)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Next: Contractor verification flow')),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.payments_outlined),
                  title: const Text('Payouts (next)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Next: Payouts screen')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
