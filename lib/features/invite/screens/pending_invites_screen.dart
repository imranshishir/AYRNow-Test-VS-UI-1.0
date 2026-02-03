import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/features/invite/models/invite_models.dart';
import 'package:ayrnow/features/invite/store/invite_store.dart';

class PendingInvitesScreen extends ConsumerWidget {
  final String? propertyId;
  final String? propertyName;
  const PendingInvitesScreen({super.key, this.propertyId, this.propertyName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inviteStoreProvider);
    final invites = state.invites.where((i) {
      if (propertyId == null) return true;
      return i.propertyId == propertyId;
    }).toList()
      ..sort((a, b) => b.lastSentAt.compareTo(a.lastSentAt));

    return Scaffold(
      appBar: AppBar(
        title: Text(propertyId == null ? 'Pending Invites' : 'Property Invites'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Text(
            propertyId == null
                ? 'All pending and historical invites'
                : 'Invites for ${propertyName ?? propertyId}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (invites.isEmpty)
            const _EmptyState()
          else
            ...invites.map((invite) => _InviteCard(invite: invite)),
        ],
      ),
    );
  }
}

class _InviteCard extends ConsumerWidget {
  final PendingInvite invite;
  const _InviteCard({required this.invite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.secondaryContainer,
          child: Icon(Icons.mark_email_unread_outlined, color: cs.onSecondaryContainer),
        ),
        title: Text(invite.contact),
        subtitle: Text(
          '${invite.propertyName} • ${invite.unitName}\n'
          '${invite.permission.label} • ${invite.status.label}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _onAction(context, ref, value),
          itemBuilder: (_) => [
            if (invite.status == InviteStatus.pending)
              const PopupMenuItem(value: 'resend', child: Text('Resend')),
            if (invite.status == InviteStatus.pending)
              const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
            if (invite.status == InviteStatus.pending)
              const PopupMenuItem(value: 'expire', child: Text('Expire')),
            const PopupMenuItem(value: 'open', child: Text('Open invite link')),
          ],
        ),
      ),
    );
  }

  void _onAction(BuildContext context, WidgetRef ref, String value) {
    final store = ref.read(inviteStoreProvider.notifier);

    switch (value) {
      case 'resend':
        store.resendInvite(invite.id);
        _toast(context, 'Invite re-sent (mock).');
        return;
      case 'cancel':
        store.cancelInvite(invite.id);
        _toast(context, 'Invite canceled.');
        return;
      case 'expire':
        store.expireInvite(invite.id);
        _toast(context, 'Invite marked as expired.');
        return;
      case 'open':
        Navigator.of(context).pushNamed('/invite/${invite.code}');
        return;
      default:
        return;
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No invites yet', style: t.textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              'Send an invite from a unit to manage tenant access.',
              style: t.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
