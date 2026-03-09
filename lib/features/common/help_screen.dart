import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Frequently Asked Questions',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ExpansionTile(
                  leading: Icon(Icons.payments_outlined),
                  title: Text('How do I pay rent?'),
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        'Go to the Payments tab and tap "Pay Rent". You can choose '
                        'from bank transfer, credit card, or mobile wallet. Payment '
                        'confirmations are sent via email and available in Receipts.',
                      ),
                    ),
                  ],
                ),
                Divider(height: 1),
                ExpansionTile(
                  leading: Icon(Icons.build_outlined),
                  title: Text('How to submit a maintenance request?'),
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        'Navigate to Maintenance > Create Ticket. Fill in a title, '
                        'description, priority, and optionally attach a photo. Your '
                        'landlord will review and assign a contractor.',
                      ),
                    ),
                  ],
                ),
                Divider(height: 1),
                ExpansionTile(
                  leading: Icon(Icons.swap_horiz_outlined),
                  title: Text('How to transfer my profile?'),
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        'Use the Transfer Profile feature to export your verified '
                        'rental history. Your new landlord can import it to skip '
                        'reference checks. Go to Profile > Transfer Profile.',
                      ),
                    ),
                  ],
                ),
                Divider(height: 1),
                ExpansionTile(
                  leading: Icon(Icons.phone_outlined),
                  title: Text('How to contact my landlord?'),
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        'You can reach your landlord through the Community tab by '
                        'posting in the building channel, or use the contact info '
                        'listed on your Lease page.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Contact Support',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.email_outlined),
                    title: Text('support@ayrnow.com'),
                    subtitle: Text('Email us anytime'),
                  ),
                  Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.phone_outlined),
                    title: Text('+1 (800) 297-6699'),
                    subtitle: Text('Mon–Fri 9am–6pm EST'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Thank you for your feedback! (demo)')),
              );
            },
            icon: const Icon(Icons.feedback_outlined),
            label: const Text('Send Feedback'),
          ),
        ],
      ),
    );
  }
}
