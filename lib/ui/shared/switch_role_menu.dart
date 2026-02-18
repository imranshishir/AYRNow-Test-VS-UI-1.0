import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/state/role_provider.dart';
import 'package:ayrnow/core/api/providers/api_client_provider.dart';
import 'package:ayrnow/core/api/providers/properties_provider.dart';
import 'package:ayrnow/core/api/providers/units_provider.dart';

class SwitchRoleMenu extends ConsumerWidget {
  const SwitchRoleMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (v) async {
        if (v == 'switch') {
          ref.read(hasChosenRoleProvider.notifier).state = false;
          ref.read(isLoggedInProvider.notifier).state = false;
          Navigator.of(context).popUntil((r) => r.isFirst);
        } else if (v == 'reset' && kDebugMode) {
          final store = ref.read(authTokenStoreProvider);
          await store.clear();
          ref.invalidate(propertiesListProvider);
          ref.invalidate(unitsListProvider);
          ref.read(hasChosenRoleProvider.notifier).state = false;
          ref.read(isLoggedInProvider.notifier).state = false;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('App state reset')),
            );
            Navigator.of(context).popUntil((r) => r.isFirst);
          }
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'switch', child: Text('Switch role')),
        if (kDebugMode)
          const PopupMenuItem(value: 'reset', child: Text('Reset app state')),
      ],
    );
  }
}
