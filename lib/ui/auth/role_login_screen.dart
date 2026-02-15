import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/models/user_role.dart';
import 'package:ayrnow/state/role_provider.dart';
import 'package:ayrnow/ui/shared/ayr_logo.dart';

class RoleLoginScreen extends ConsumerStatefulWidget {
  final VoidCallback? onRoleChosen;

  const RoleLoginScreen({super.key, this.onRoleChosen});

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
          const SizedBox(height: 8),
          const Center(child: AyrLogo(size: 80)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'AYRNOW',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
          const SizedBox(height: 24),
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
              widget.onRoleChosen?.call();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
