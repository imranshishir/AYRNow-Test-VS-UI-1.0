import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/providers.dart';
import '../models/household_models.dart';
const _demoUnitId = 'unit-1';

class TenantHouseholdScreen extends ConsumerWidget {
  const TenantHouseholdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(householdMembersProvider(_demoUnitId));

    return Scaffold(
      appBar: AppBar(title: const Text('Household')),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(err.toString(), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        data: (members) {
          if (members.isEmpty) {
            return _EmptyState(
              onInvite: () => _openInvite(context, ref),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final m = members[i];
              return _MemberCard(
                member: m,
                onDeactivate: m.role != HouseholdRole.primaryTenant && m.status == HouseholdStatus.active
                    ? () => _deactivate(context, ref, m)
                    : null,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openInvite(context, ref),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Invite member'),
      ),
    );
  }

  Future<void> _openInvite(BuildContext context, WidgetRef ref) async {
    await Navigator.pushNamed(context, '/T-50/invite');
    ref.invalidate(householdMembersProvider);
  }

  Future<void> _deactivate(BuildContext context, WidgetRef ref, HouseholdMember m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate member?'),
        content: Text('${m.name} will be marked as inactive.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Deactivate')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(householdControllerProvider).deactivateMember(m.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${m.name} has been deactivated.')),
        );
      }
    }
  }
}

class _MemberCard extends StatelessWidget {
  final HouseholdMember member;
  final VoidCallback? onDeactivate;

  const _MemberCard({required this.member, this.onDeactivate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        title: Text(member.name),
        subtitle: Text('${member.role.label} • ${member.status.label}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusChip(status: member.status),
            const SizedBox(width: 6),
            _RoleChip(role: member.role),
            if (onDeactivate != null) ...[
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (_) => onDeactivate!(),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'deactivate',
                    child: ListTile(
                      leading: Icon(Icons.person_remove_outlined),
                      title: Text('Deactivate'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final HouseholdStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == HouseholdStatus.active
        ? Colors.green
        : status == HouseholdStatus.invited
            ? Colors.orange
            : Colors.grey;
    return Chip(
      label: Text(status.label, style: TextStyle(fontSize: 11, color: color)),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withOpacity(0.15),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final HouseholdRole role;

  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(role.label, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onInvite;

  const _EmptyState({required this.onInvite});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No household members yet',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Invite co-tenants or family members to your household.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onInvite,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Invite member'),
            ),
          ],
        ),
      ),
    );
  }
}
