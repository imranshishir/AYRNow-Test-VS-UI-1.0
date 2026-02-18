import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/providers.dart';
import '../../core/state/backend_flags.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (kDebugMode) ...[
            const Text('Dev', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: SwitchListTile(
                title: const Text('Use API backend'),
                subtitle: const Text('Rent, tickets, notifications from localhost:8080'),
                value: ref.watch(useApiBackendProvider),
                onChanged: (v) {
                  ref.read(useApiBackendProvider.notifier).state = v;
                  ref.invalidate(rentBoardProvider);
                  ref.invalidate(ticketsProvider);
                  ref.invalidate(notificationsProvider);
                  ref.invalidate(notificationsUnreadCountProvider);
                  ref.invalidate(meProvider);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}
