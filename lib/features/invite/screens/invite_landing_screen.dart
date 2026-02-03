import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/features/invite/models/invite_models.dart';
import 'package:ayrnow/features/invite/store/invite_store.dart';
import 'package:ayrnow/features/invite/screens/invite_accept_screen.dart';

class InviteLandingScreen extends ConsumerWidget {
  final String code;
  const InviteLandingScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invite = ref.watch(inviteStoreProvider.notifier).findByCode(code);

    return Scaffold(
      appBar: AppBar(title: const Text('Tenant Invite')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          if (invite == null)
            const _InvalidInvite()
          else if (invite.isPending && !invite.isExpiredByTime)
            _PendingInviteCard(invite: invite)
          else
            _ResolvedInviteCard(invite: invite),
        ],
      ),
    );
  }
}

class _PendingInviteCard extends ConsumerWidget {
  final PendingInvite invite;
  const _PendingInviteCard({required this.invite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are invited to join a unit', style: t.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${invite.propertyName} • ${invite.unitName}', style: t.textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text('Access: ${invite.permission.label}', style: t.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text('Contact: ${invite.contact}', style: t.textTheme.bodyMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => InviteAcceptScreen(code: invite.code)),
                );
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Accept invite'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(inviteStoreProvider.notifier).declineInvite(invite.code);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invite declined.')),
                );
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
              label: const Text('Decline'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResolvedInviteCard extends StatelessWidget {
  final PendingInvite invite;
  const _ResolvedInviteCard({required this.invite});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invite status: ${invite.status.label}', style: t.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${invite.propertyName} • ${invite.unitName}', style: t.textTheme.bodyLarge),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvalidInvite extends StatelessWidget {
  const _InvalidInvite();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invite not found', style: t.textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              'This invite link is invalid or no longer available.',
              style: t.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
