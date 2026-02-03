import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/features/invite/store/invite_store.dart';
import 'package:ayrnow/features/invite/models/invite_models.dart';

class InviteAcceptScreen extends ConsumerWidget {
  final String code;
  const InviteAcceptScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invite = ref.watch(inviteStoreProvider.notifier).findByCode(code);

    if (invite == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Accept Invite')),
        body: const Center(child: Text('Invite not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Accept Invite')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${invite.propertyName} • ${invite.unitName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Permission: ${invite.permission.label}'),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () {
                      final ok = ref.read(inviteStoreProvider.notifier).acceptInvite(code);
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invite is no longer available.')),
                        );
                        Navigator.of(context).pop();
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Access activated. You are attached to this unit.'),
                        ),
                      );
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Accept & activate'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
