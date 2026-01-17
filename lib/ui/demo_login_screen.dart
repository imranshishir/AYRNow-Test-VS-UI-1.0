import 'package:flutter/material.dart';
import 'package:ayrnow/state/current_role_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/role.dart';
import '../core/state/providers.dart';

class DemoLoginScreen extends ConsumerStatefulWidget {
  const DemoLoginScreen({super.key});

  @override
  ConsumerState<DemoLoginScreen> createState() => _DemoLoginScreenState();
}

class _DemoLoginScreenState extends ConsumerState<DemoLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _otp = TextEditingController();

  UserRole _role = UserRole.landlord;
  bool _otpStep = false;

  // Demo credentials per role (adjust as you like)
  static const _demo = <UserRole, Map<String, String>>{
    UserRole.landlord: {'email': 'landlord@ayrnow.demo', 'pass': 'Landlord123', 'otp': '123456'},
    UserRole.tenant: {'email': 'tenant@ayrnow.demo', 'pass': 'Tenant123', 'otp': '123456'},
    UserRole.contractor: {'email': 'contractor@ayrnow.demo', 'pass': 'Contractor123', 'otp': '123456'},
    UserRole.guard: {'email': 'guard@ayrnow.demo', 'pass': 'Guard123', 'otp': '123456'},
    UserRole.investor: {'email': 'investor@ayrnow.demo', 'pass': 'Investor123', 'otp': '123456'},
    UserRole.admin: {'email': 'admin@ayrnow.demo', 'pass': 'Admin123', 'otp': '123456'},
  };

  @override
  void initState() {
    super.initState();
    _applyRole(_role);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _applyRole(UserRole role) {
    final data = _demo[role]!;
    _email.text = data['email']!;
    _password.text = data['pass']!;
    _otp.text = data['otp']!;
  }

  String _roleLabel(UserRole r) {
    switch (r) {
      case UserRole.tenant:
        return 'Tenant';
      case UserRole.landlord:
        return 'Landlord';
      case UserRole.contractor:
        return 'Contractor';
      case UserRole.guard:
        return 'Security Guard';
      case UserRole.investor:
        return 'Investor';
      case UserRole.admin:
        return 'Admin';
    }
  }

  IconData _roleIcon(UserRole r) {
    switch (r) {
      case UserRole.tenant:
        return Icons.person_outline;
      case UserRole.landlord:
        return Icons.home_outlined;
      case UserRole.contractor:
        return Icons.handyman_outlined;
      case UserRole.guard:
        return Icons.security_outlined;
      case UserRole.investor:
        return Icons.trending_up_outlined;
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }

  void _continue() {
    // Set the role globally (whatever your app uses today)
    ref.read(currentRoleProvider.notifier).state = _role;

    // Fake OTP flow
    if (!_otpStep) {
      setState(() => _otpStep = true);
      // optional auto-advance:
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _verifyOtp();
      });
      return;
    }

    _verifyOtp();
  }

  void _verifyOtp() {
    // Accept any 6 digits, but we prefill 123456
    // Navigate to your real "shell"
    Navigator.pushReplacementNamed(context, '/shell');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: cs.primary.withOpacity(.12),
                      child: Icon(Icons.home_work_outlined, color: cs.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AYRNOW', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                          SizedBox(height: 2),
                          Text('Demo Login • role-based flow', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<UserRole>(
                          value: _role,
                          decoration: const InputDecoration(
                            labelText: 'Select role',
                            border: OutlineInputBorder(),
                          ),
                          items: UserRole.values
                              .map((r) => DropdownMenuItem(
                                    value: r,
                                    child: Row(
                                      children: [
                                        Icon(_roleIcon(r), size: 18),
                                        const SizedBox(width: 10),
                                        Text(_roleLabel(r)),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (r) {
                            if (r == null) return;
                            setState(() {
                              _role = r;
                              _otpStep = false;
                            });
                            _applyRole(r);
                          },
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: _email,
                          decoration: const InputDecoration(
                            labelText: 'Email / Username',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: !_otpStep
                              ? const SizedBox.shrink()
                              : Column(
                                  key: const ValueKey('otp'),
                                  children: [
                                    TextField(
                                      controller: _otp,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'OTP (prefilled demo)',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _continue,
                            child: Text(_otpStep ? 'Verify & Enter App' : 'Continue (Fake OTP)'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This is a demo-only login. Role selection auto-fills credentials and OTP.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
