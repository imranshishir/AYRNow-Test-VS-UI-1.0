enum UserRole { landlord, tenant, contractor, guard }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.landlord: return 'Landlord';
      case UserRole.tenant: return 'Tenant';
      case UserRole.contractor: return 'Contractor';
      case UserRole.guard: return 'Security Guard';
    }
  }

  String get short {
    switch (this) {
      case UserRole.landlord: return 'LANDLORD';
      case UserRole.tenant: return 'TENANT';
      case UserRole.contractor: return 'CONTRACTOR';
      case UserRole.guard: return 'GUARD';
    }
  }
}
