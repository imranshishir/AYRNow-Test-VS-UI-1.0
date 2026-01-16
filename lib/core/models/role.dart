enum UserRole { landlord, tenant, contractor, guard, investor, admin }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.landlord: return 'Landlord';
      case UserRole.tenant: return 'Tenant';
      case UserRole.contractor: return 'Contractor';
      case UserRole.guard: return 'Security Guard';
      case UserRole.investor: return 'Investor';
      case UserRole.admin: return 'Admin';
    }
  }
}
