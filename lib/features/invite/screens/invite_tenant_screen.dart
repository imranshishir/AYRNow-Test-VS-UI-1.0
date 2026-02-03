import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/features/invite/models/invite_models.dart';
import 'package:ayrnow/features/invite/store/invite_store.dart';
import 'package:ayrnow/features/landlord/unit/mock_unit_data.dart';

class InviteTenantScreen extends ConsumerStatefulWidget {
  final UnitBundle bundle;
  const InviteTenantScreen({super.key, required this.bundle});

  @override
  ConsumerState<InviteTenantScreen> createState() => _InviteTenantScreenState();
}

class _InviteTenantScreenState extends ConsumerState<InviteTenantScreen> {
  final _contact = TextEditingController();
  InvitePermission _permission = InvitePermission.viewOnly;

  @override
  void dispose() {
    _contact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Invite Tenant')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.bundle.propertyName, style: t.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(widget.bundle.unitName, style: t.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Email or phone', style: t.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _contact,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'tenant@email.com or (555) 555-5555',
              prefixIcon: Icon(Icons.alternate_email),
            ),
          ),
          const SizedBox(height: 14),
          Text('Permission', style: t.textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<InvitePermission>(
            segments: InvitePermission.values
                .map(
                  (p) => ButtonSegment<InvitePermission>(
                    value: p,
                    label: Text(p.label),
                  ),
                )
                .toList(),
            selected: {_permission},
            onSelectionChanged: (next) => setState(() => _permission = next.first),
          ),
          const SizedBox(height: 8),
          Text(_permission.description, style: t.textTheme.bodySmall),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _sendInvite,
            icon: const Icon(Icons.send_outlined),
            label: const Text('Send invite'),
          ),
        ],
      ),
    );
  }

  void _sendInvite() {
    final contact = _contact.text.trim();
    if (contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an email or phone to continue.')),
      );
      return;
    }

    final invite = ref.read(inviteStoreProvider.notifier).createInvite(
          propertyId: widget.bundle.propertyId,
          propertyName: widget.bundle.propertyName,
          unitId: widget.bundle.unitId,
          unitName: widget.bundle.unitName,
          contact: contact,
          permission: _permission,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invite sent to ${invite.contact}.')),
    );
    Navigator.of(context).pop(true);
  }
}
