import 'package:ayrnow/core/models/role.dart';

/// DEV-ONLY: Predefined test users for development without backend.
/// Do NOT use in release builds. Gated by kDebugMode.
class DevTestUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? propertyId;
  final String? unitId;

  const DevTestUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.propertyId,
    this.unitId,
  });
}

/// DEV-ONLY: List of test users for quick login. Use via loginAsDevUser.
const List<DevTestUser> devTestUsers = [
  DevTestUser(
    id: 'dev-landlord-1',
    name: 'Demo Landlord',
    email: 'landlord@dev.ayrnow.com',
    role: UserRole.landlord,
    propertyId: 'dev-prop-1',
    unitId: null,
  ),
  DevTestUser(
    id: 'dev-tenant-1',
    name: 'Demo Tenant',
    email: 'tenant@dev.ayrnow.com',
    role: UserRole.tenant,
    propertyId: 'dev-prop-1',
    unitId: 'dev-unit-1',
  ),
  DevTestUser(
    id: 'dev-contractor-1',
    name: 'Demo Contractor',
    email: 'contractor@dev.ayrnow.com',
    role: UserRole.contractor,
  ),
  DevTestUser(
    id: 'dev-guard-1',
    name: 'Demo Security Guard',
    email: 'guard@dev.ayrnow.com',
    role: UserRole.guard,
  ),
];
