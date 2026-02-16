import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/features/account_management/models/managed_user_model.dart';
import 'package:ayrnow/features/account_management/services/managed_user_provider.dart';
import 'package:ayrnow/features/account_management/screens/add_managed_user_screen.dart';
import 'package:ayrnow/core/session/tenant_context.dart';
import 'package:ayrnow/ui/shared/widgets/empty_state_widget.dart';
import 'package:ayrnow/ui/shared/widgets/section_card.dart';
import 'package:ayrnow/ui/shared/widgets/primary_button.dart';
import 'package:ayrnow/ui/shared/widgets/status_badge.dart';

class FinancialAdminUsersScreen extends ConsumerWidget {
  const FinancialAdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(managedUserServiceProvider);
    final users = service.users
        .where((u) =>
            u.isFinancialAdmin &&
            (u.ownerAccountId == null ||
                u.ownerAccountId == kLandlordAccountId))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Financial & Admin')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (users.isEmpty)
            EmptyStateWidget(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No admin users yet',
              subtitle: 'Add managers, accountants, or family with financial access.',
              actionLabel: 'Add Admin User',
              onAction: () => _openAdd(context),
            )
          else
            ...users.map((u) => SectionCard(
                  child: _UserRow(
                    user: u,
                    onRemove: () => _confirmRemove(context, ref, u),
                  ),
                )),
          if (users.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: PrimaryButton(
                label: 'Add Admin User',
                onPressed: () => _openAdd(context),
                icon: Icons.person_add,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openAdd(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddManagedUserScreen(
          isLandlord: true,
          category: ManagedUserCategory.financialAdmin,
        ),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref, ManagedUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove user?'),
        content: Text('${user.fullName} will lose access. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      ref.read(managedUserServiceProvider.notifier).removeUser(user.id);
    }
  }
}

class _UserRow extends StatelessWidget {
  final ManagedUser user;
  final VoidCallback onRemove;

  const _UserRow({required this.user, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isActive = user.isActive && user.status == ManagedUserStatus.active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: t.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(user.email, style: t.textTheme.bodySmall),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onRemove,
              color: cs.error,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            user.displayRoleLabel,
            style: t.textTheme.labelSmall?.copyWith(color: cs.onSecondaryContainer, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 6),
        Text(user.displayPermissionLabel, style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 8),
        StatusBadge.managedUser(isActive: isActive),
      ],
    );
  }
}
