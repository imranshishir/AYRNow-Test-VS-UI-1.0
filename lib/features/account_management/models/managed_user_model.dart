enum ManagedUserCategory {
  financialAdmin,
  operational,
}

extension ManagedUserCategoryX on ManagedUserCategory {
  String get label => switch (this) {
        ManagedUserCategory.financialAdmin => 'Financial & Admin',
        ManagedUserCategory.operational => 'Operational Staff',
      };
}

enum ManagedUserRoleType {
  manager,
  accountant,
  family,
  security,
  cleaning,
  maintenance,
  contractor,
}

extension ManagedUserRoleTypeX on ManagedUserRoleType {
  String get label => switch (this) {
        ManagedUserRoleType.manager => 'Property Manager',
        ManagedUserRoleType.accountant => 'Accountant',
        ManagedUserRoleType.family => 'Family Member',
        ManagedUserRoleType.security => 'Security Guard',
        ManagedUserRoleType.cleaning => 'Cleaning Staff',
        ManagedUserRoleType.maintenance => 'Maintenance',
        ManagedUserRoleType.contractor => 'Contractor',
      };

  ManagedUserCategory get category => switch (this) {
        ManagedUserRoleType.manager ||
        ManagedUserRoleType.accountant ||
        ManagedUserRoleType.family =>
          ManagedUserCategory.financialAdmin,
        ManagedUserRoleType.security ||
        ManagedUserRoleType.cleaning ||
        ManagedUserRoleType.maintenance ||
        ManagedUserRoleType.contractor =>
          ManagedUserCategory.operational,
      };
}

enum PermissionScope {
  fullAccess,
  financialOnly,
  maintenanceOnly,
  visitorOnly,
  limitedAccess,
}

extension PermissionScopeX on PermissionScope {
  String get label => switch (this) {
        PermissionScope.fullAccess => 'Full access',
        PermissionScope.financialOnly => 'Financial only',
        PermissionScope.maintenanceOnly => 'Maintenance only',
        PermissionScope.visitorOnly => 'Visitor + SOS + Entry logs',
        PermissionScope.limitedAccess => 'Customizable / Limited',
      };
}

enum ManagedUserRole {
  manager,
  accountant,
  family,
  coTenant,
}

extension ManagedUserRoleX on ManagedUserRole {
  String get label => switch (this) {
        ManagedUserRole.manager => 'Manager',
        ManagedUserRole.accountant => 'Accountant',
        ManagedUserRole.family => 'Family',
        ManagedUserRole.coTenant => 'Co-Tenant',
      };
}

enum ManagedUserPermission {
  fullAccess,
  limitedAccess,
  viewOnly,
}

extension ManagedUserPermissionX on ManagedUserPermission {
  String get label => switch (this) {
        ManagedUserPermission.fullAccess => 'Full Access',
        ManagedUserPermission.limitedAccess => 'Limited Access',
        ManagedUserPermission.viewOnly => 'View Only',
      };
}

enum ManagedUserStatus { active, revoked }

extension ManagedUserStatusX on ManagedUserStatus {
  String get label => switch (this) {
        ManagedUserStatus.active => 'Active',
        ManagedUserStatus.revoked => 'Revoked',
      };
}

class ManagedUser {
  final String id;
  final String fullName;
  final String email;
  final String roleLabel;
  final String permissionLabel;
  final ManagedUserStatus status;
  final ManagedUserRoleType? roleType;
  final ManagedUserCategory? category;
  final PermissionScope? permissionScope;
  final bool isActive;
  final DateTime createdAt;
  /// Owner of this record (landlord or tenant account). Null = legacy; treat as current account in filters.
  final String? ownerAccountId;

  const ManagedUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roleLabel,
    required this.permissionLabel,
    this.status = ManagedUserStatus.active,
    this.roleType,
    this.category,
    this.permissionScope,
    this.isActive = true,
    required this.createdAt,
    this.ownerAccountId,
  });

  String get displayRoleLabel => roleType?.label ?? roleLabel;
  String get displayPermissionLabel => permissionScope?.label ?? permissionLabel;

  bool get isFinancialAdmin =>
      category == ManagedUserCategory.financialAdmin ||
      (roleType != null && roleType!.category == ManagedUserCategory.financialAdmin);
  bool get isOperational =>
      category == ManagedUserCategory.operational ||
      (roleType != null && roleType!.category == ManagedUserCategory.operational);
}
