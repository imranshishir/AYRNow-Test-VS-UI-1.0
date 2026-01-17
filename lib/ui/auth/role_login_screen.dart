import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/models/user_role.dart';
import 'package:ayrnow/state/role_provider.dart';
import 'package:ayrnow/ui/shared/ayr_logo.dart';

class RoleLoginScreen extends ConsumerStatefulWidget {
  const RoleLoginScreen({super.key});

  @override
  ConsumerState<RoleLoginScreen> createState() => _RoleLoginScreenState();
}

class _RoleLoginScreenState extends ConsumerState<RoleLoginScreen> {
  final _email = TextEditingController(text: 'demo@ayrnow.com');
  final _pass = TextEditingController(text: 'password');
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentRoleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AYRNOW'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const SizedBox(height: 10),
            const Center(child: AyrLogo(size: 64)),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Access your rental now',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 22),

            // ROLE DROPDOWN (above username/password, as you requested)
            Text('Select role', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserRole>(
              value: role,
              onChanged: (v) {
                if (v != null) ref.read(currentRoleProvider.notifier).state = v;
              },
              items: UserRole.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                  .toList(),
            ),

            const SizedBox(height: 16),
            Text('Username / Email', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'name@company.com'),
            ),

            const SizedBox(height: 14),
            Text('Password', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _pass,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: '••••••••',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
            ),

            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                ref.read(isLoggedInProvider.notifier).state = true;
              },
              child: Text('Continue as ${role.label}'),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // quick role reset convenience
                      ref.read(currentRoleProvider.notifier).state = UserRole.landlord;
                    },
                    child: const Text('Reset role'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demo: forgot password')),
                      );
                    },
                    child: const Text('Forgot password?'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            _demoHint(context),
          ],
        ),
      ),
    );
  }

  Widget _demoHint(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Demo app: role changes the home experience.\n'
              'You can always switch roles from the top-right menu after login.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
