import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/models/user_role.dart';
import 'package:ayrnow/state/role_provider.dart';

class RoleLoginScreen extends ConsumerStatefulWidget {
  const RoleLoginScreen({super.key});

  @override
  ConsumerState<RoleLoginScreen> createState() => _RoleLoginScreenState();
}

class _RoleLoginScreenState extends ConsumerState<RoleLoginScreen> {
  UserRole _selectedRole = UserRole.landlord;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(
            'Choose how you want to continue',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<UserRole>(
            value: _selectedRole,
            items: UserRole.values
                .map(
                  (r) => DropdownMenuItem<UserRole>(
                    value: r,
                    child: Text(r.label),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedRole = v);
              }
            },
            decoration: const InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              ref.read(currentRoleProvider.notifier).state = _selectedRole;
              ref.read(isLoggedInProvider.notifier).state = true;
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
