import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/state/role_provider.dart';

class SwitchRoleMenu extends ConsumerWidget {
  const SwitchRoleMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'switch') {
          // Go back to RoleLoginScreen
          ref.read(isLoggedInProvider.notifier).state = false;
          // Also pop any pushed screens (best effort)
          Navigator.of(context).popUntil((r) => r.isFirst);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'switch', child: Text('Switch role')),
      ],
    );
  }
}
