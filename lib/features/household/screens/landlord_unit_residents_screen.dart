import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/providers.dart';
import '../models/household_models.dart';
class LandlordUnitResidentsScreen extends ConsumerWidget {
  final String unitId;
  final String? unitLabel;

  const LandlordUnitResidentsScreen({
    super.key,
    required this.unitId,
    this.unitLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(householdMembersProvider(unitId));

    return Scaffold(
      appBar: AppBar(
        title: Text(unitLabel != null ? 'Residents: $unitLabel' : 'Residents & Family'),
        actions: [
          IconButton(
            onPressed: () => _openLeasePacketFlow(context),
            icon: const Icon(Icons.description_outlined),
            tooltip: 'Prepare lease packet',
          ),
        ],
      ),
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'No residents yet',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final m = members[i];
              return _ReadOnlyMemberCard(member: m);
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
    await Navigator.pushNamed(
      context,
      '/T-50/invite',
      arguments: {'unitId': unitId, 'isLandlord': true},
    );
    ref.invalidate(householdMembersProvider);
  }

  void _openLeasePacketFlow(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/L-26',
      arguments: {
        'unitId': unitId,
        'unitLabel': unitLabel,
      },
    );
  }
}

class _ReadOnlyMemberCard extends StatelessWidget {
  final HouseholdMember member;

  const _ReadOnlyMemberCard({required this.member});

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
