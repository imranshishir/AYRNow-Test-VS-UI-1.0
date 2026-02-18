import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/providers.dart';
import '../../notifications/models/notification_models.dart';
import '../models/household_models.dart';

const _demoUnitId = 'unit-1';

class InviteHouseholdMemberScreen extends ConsumerStatefulWidget {
  final String unitId;
  final HouseholdRole? defaultRole;
  final bool isLandlord;

  const InviteHouseholdMemberScreen({
    super.key,
    this.unitId = _demoUnitId,
    this.defaultRole,
    this.isLandlord = false,
  });

  @override
  ConsumerState<InviteHouseholdMemberScreen> createState() => _InviteHouseholdMemberScreenState();
}

class _InviteHouseholdMemberScreenState extends ConsumerState<InviteHouseholdMemberScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  HouseholdRole _role = HouseholdRole.familyMember;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.defaultRole != null) _role = widget.defaultRole!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty && _emailController.text.trim().isNotEmpty && !_loading;

  String _generateInviteCode() {
    final n = DateTime.now().millisecondsSinceEpoch % 1000000;
    final chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return 'AYR-${chars[(n ~/ 10000) % chars.length]}${chars[(n ~/ 1000) % chars.length]}${chars[(n ~/ 100) % chars.length]}${chars[(n ~/ 10) % chars.length]}${chars[n % chars.length]}';
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(householdControllerProvider).inviteMember(
            unitId: widget.unitId,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            role: _role,
          );
      if (!mounted) return;
      final code = _generateInviteCode();
      ref.read(notificationsControllerProvider).add(AppNotification(
        id: 'n-${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.householdInvite,
        title: 'Household invite created',
        body: 'Invite code: $code',
        createdAt: DateTime.now(),
        route: '/T-50',
        targetRole: NotificationTargetRole.tenant,
      ));
      await _showInviteCodeSheet(context, code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invite created. Sharing links will be enabled after backend integration.'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    } finally {
      if (mounted && _loading) setState(() => _loading = false);
    }
  }

  Future<void> _showInviteCodeSheet(BuildContext context, String code) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Invite Code',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                code,
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Code copied to clipboard')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy Code'),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<HouseholdRole>> get _roleOptions {
    final roles = widget.isLandlord
        ? [HouseholdRole.coTenant, HouseholdRole.familyMember, HouseholdRole.landlordAssistant]
        : [HouseholdRole.coTenant, HouseholdRole.familyMember];
    return roles.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Invite member')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name *',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone (optional)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<HouseholdRole>(
            value: _role,
            decoration: const InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(),
            ),
            items: _roleOptions,
            onChanged: (v) => setState(() => _role = v ?? _role),
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton.icon(
            onPressed: _canSubmit ? _submit : null,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(_loading ? 'Creating…' : 'Create Invite'),
          ),
        ],
      ),
    );
  }
}
