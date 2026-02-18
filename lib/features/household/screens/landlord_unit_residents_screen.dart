import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/state/providers.dart';
import '../models/household_models.dart';
import 'invite_household_member_screen.dart';

const _demoUnitId = 'unit-1';

class LandlordUnitResidentsScreen extends ConsumerWidget {
  final String unitId;
  final String? unitLabel;

  const LandlordUnitResidentsScreen({
    super.key,
    this.unitId = _demoUnitId,
    this.unitLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(householdMembersProvider(unitId));

    return Scaffold(
      appBar: AppBar(
        title: Text(unitLabel != null ? 'Residents: $unitLabel' : 'L-50 • Residents'),
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
        label: const Text('Invite Member'),
      ),
    );
  }

  Future<void> _openInvite(BuildContext context, WidgetRef ref) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InviteHouseholdMemberScreen(unitId: unitId, isLandlord: true),
      ),
    );
    ref.invalidate(householdMembersProvider);
  }
}

class _ReadOnlyMemberCard extends StatelessWidget {
  final HouseholdMember member;

  const _ReadOnlyMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(member.name),
        subtitle: Text(member.email),
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
