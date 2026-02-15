import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/features/account_management/models/managed_user_model.dart';
import 'package:ayrnow/features/account_management/services/managed_user_provider.dart';
import 'package:ayrnow/features/account_management/screens/add_managed_user_screen.dart';
import 'package:ayrnow/features/account_management/screens/financial_admin_users_screen.dart';
import 'package:ayrnow/features/account_management/screens/operational_staff_screen.dart';
import 'package:ayrnow/core/session/tenant_context.dart';
import 'package:ayrnow/ui/shared/widgets/empty_state_widget.dart';
import 'package:ayrnow/ui/shared/widgets/section_card.dart';
import 'package:ayrnow/ui/shared/widgets/status_badge.dart';

class ManagedUsersScreen extends ConsumerWidget {
  final bool isLandlord;

  const ManagedUsersScreen({super.key, required this.isLandlord});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = isLandlord ? 'Managed Users' : 'Household Access';

    if (isLandlord) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            SectionCard(
              title: 'Financial & Admin',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FinancialAdminUsersScreen()),
              ),
              child: Text(
                'Manage financial and administrative access',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: 'Operational Staff',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OperationalStaffScreen()),
              ),
              child: Text(
                'Manage on-site and service staff',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    final service = ref.watch(managedUserServiceProvider);
    final tenantAccountId = ref.watch(tenantContextProvider).tenantAccountId;
    ref.read(managedUserServiceProvider.notifier).backfillOwnerForTenant(tenantAccountId);
    final users = service.users
        .where((u) => u.ownerAccountId == tenantAccountId)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            'Add family members to help manage rent and requests',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          if (users.isEmpty)
            EmptyStateWidget(
              icon: Icons.people_outline,
              title: 'No household members yet',
              subtitle: 'Add family members to help manage rent and requests',
              actionLabel: 'Add household member',
              onAction: () => _openAddUser(context),
            )
          else
            ...users.map((u) => SectionCard(
                  child: _UserCardContent(
                    user: u,
                    onRemove: () => _confirmRemove(context, ref, u),
                  ),
                )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddUser(context),
        icon: const Icon(Icons.add),
        label: const Text('Add household member'),
      ),
    );
  }

  void _openAddUser(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddManagedUserScreen(isLandlord: isLandlord),
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    ManagedUser user,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove user?'),
        content: Text(
          '${user.fullName} will lose access. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
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

class _UserCardContent extends StatelessWidget {
  final ManagedUser user;
  final VoidCallback onRemove;

  const _UserCardContent({required this.user, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
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
                  Text(
                    user.fullName,
                    style: t.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: t.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onRemove,
              color: t.colorScheme.error,
            ),
          ],
        ),
        const SizedBox(height: 10),
        _RoleBadge(label: user.displayRoleLabel),
        const SizedBox(height: 6),
        Text(
          user.displayPermissionLabel,
          style: t.textTheme.bodySmall?.copyWith(
            color: t.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        StatusBadge.managedUser(isActive: isActive),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;

  const _RoleBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
