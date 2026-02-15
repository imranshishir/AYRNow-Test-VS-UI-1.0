import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/features/account_management/models/managed_user_model.dart';
import 'package:ayrnow/features/account_management/services/managed_user_provider.dart';
import 'package:ayrnow/core/session/tenant_context.dart';
import 'package:ayrnow/ui/shared/widgets/primary_button.dart';
import 'package:ayrnow/ui/shared/widgets/confirmation_screen.dart';

PermissionScope _recommendedScopeForRole(ManagedUserRoleType role) {
  return switch (role) {
    ManagedUserRoleType.manager => PermissionScope.fullAccess,
    ManagedUserRoleType.accountant => PermissionScope.financialOnly,
    ManagedUserRoleType.family => PermissionScope.limitedAccess,
    ManagedUserRoleType.security => PermissionScope.visitorOnly,
    ManagedUserRoleType.cleaning => PermissionScope.maintenanceOnly,
    ManagedUserRoleType.maintenance => PermissionScope.maintenanceOnly,
    ManagedUserRoleType.contractor => PermissionScope.maintenanceOnly,
  };
}

List<ManagedUserRoleType> _rolesForCategory(ManagedUserCategory? category) {
  if (category == ManagedUserCategory.financialAdmin) {
    return [ManagedUserRoleType.manager, ManagedUserRoleType.accountant, ManagedUserRoleType.family];
  }
  if (category == ManagedUserCategory.operational) {
    return [ManagedUserRoleType.security, ManagedUserRoleType.cleaning, ManagedUserRoleType.maintenance, ManagedUserRoleType.contractor];
  }
  return ManagedUserRoleType.values;
}

class AddManagedUserScreen extends ConsumerStatefulWidget {
  final bool isLandlord;
  final ManagedUserCategory? category;

  const AddManagedUserScreen({super.key, required this.isLandlord, this.category});

  @override
  ConsumerState<AddManagedUserScreen> createState() => _AddManagedUserScreenState();
}

class _AddManagedUserScreenState extends ConsumerState<AddManagedUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  late ManagedUserRoleType _roleType;
  late PermissionScope _permissionScope;
  ManagedUserRole _roleTenant = ManagedUserRole.family;
  ManagedUserPermission _permissionTenant = ManagedUserPermission.limitedAccess;
  bool _loading = false;

  List<ManagedUserRoleType> get _roleOptions => _rolesForCategory(widget.category);

  @override
  void initState() {
    super.initState();
    final opts = _rolesForCategory(widget.category);
    _roleType = opts.isNotEmpty ? opts.first : ManagedUserRoleType.manager;
    _permissionScope = _recommendedScopeForRole(_roleType);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  static bool _isValidEmail(String v) {
    return RegExp(r'^[\w\-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v.trim());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final now = DateTime.now();
    final id = 'mu-${now.millisecondsSinceEpoch}';

    final ownerId = widget.isLandlord
        ? kLandlordAccountId
        : ref.read(tenantContextProvider).tenantAccountId;

    final ManagedUser user;
    if (widget.isLandlord) {
      user = ManagedUser(
        id: id,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        roleLabel: _roleType.label,
        permissionLabel: _permissionScope.label,
        status: ManagedUserStatus.active,
        roleType: _roleType,
        category: _roleType.category,
        permissionScope: _permissionScope,
        isActive: true,
        createdAt: now,
        ownerAccountId: ownerId,
      );
    } else {
      user = ManagedUser(
        id: id,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        roleLabel: _roleTenant.label,
        permissionLabel: _permissionTenant.label,
        status: ManagedUserStatus.active,
        isActive: true,
        createdAt: now,
        ownerAccountId: ownerId,
      );
    }

    await ref.read(managedUserServiceProvider.notifier).addUser(user);

    if (!mounted) return;
    setState(() => _loading = false);

    if (widget.isLandlord) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConfirmationScreen(
            title: 'User invited successfully',
            message: '${user.fullName} has been added with ${user.displayPermissionLabel}.',
            primaryButtonLabel: 'Back to list',
            onPrimaryPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConfirmationScreen(
            title: 'Household member added',
            message: '${user.fullName} has been added to your household.',
            primaryButtonLabel: 'Back to Household Access',
            onPrimaryPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            secondaryButtonLabel: 'Add another',
            onSecondaryPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isLandlord ? 'Add User' : 'Add household member'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  hintText: 'Jane Smith',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter full name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'jane@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter email';
                  if (!_isValidEmail(v)) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (widget.isLandlord) ...[
                DropdownButtonFormField<ManagedUserRoleType>(
                  value: _roleType,
                  decoration: const InputDecoration(
                    labelText: 'Role type',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: _roleOptions
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.label),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _roleType = v;
                        _permissionScope = _recommendedScopeForRole(v);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PermissionScope>(
                  value: _permissionScope,
                  decoration: const InputDecoration(
                    labelText: 'Permission scope',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  items: PermissionScope.values
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.label),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _permissionScope = v);
                  },
                ),
              ] else ...[
                DropdownButtonFormField<ManagedUserRole>(
                  value: _roleTenant,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: [ManagedUserRole.family, ManagedUserRole.coTenant]
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.label),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _roleTenant = v;
                        _permissionTenant = v == ManagedUserRole.family
                            ? ManagedUserPermission.limitedAccess
                            : ManagedUserPermission.limitedAccess;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ManagedUserPermission>(
                  value: _permissionTenant,
                  decoration: const InputDecoration(
                    labelText: 'Permission level',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  items: ManagedUserPermission.values
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.label),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _permissionTenant = v);
                  },
                ),
              ],
              const SizedBox(height: 28),
              PrimaryButton(
                label: widget.isLandlord ? 'Invite user' : 'Add household member',
                isLoading: _loading,
                onPressed: _submit,
                icon: Icons.person_add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
