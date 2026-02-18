import 'package:flutter/foundation.dart';

enum HouseholdRole {
  primaryTenant,
  coTenant,
  familyMember,
  landlordAssistant,
}

extension HouseholdRoleX on HouseholdRole {
  String get label => switch (this) {
        HouseholdRole.primaryTenant => 'Primary',
        HouseholdRole.coTenant => 'Co-tenant',
        HouseholdRole.familyMember => 'Family',
        HouseholdRole.landlordAssistant => 'Assistant',
      };
}

enum HouseholdStatus {
  invited,
  active,
  inactive,
}

extension HouseholdStatusX on HouseholdStatus {
  String get label => switch (this) {
        HouseholdStatus.invited => 'Invited',
        HouseholdStatus.active => 'Active',
        HouseholdStatus.inactive => 'Inactive',
      };
}

@immutable
class HouseholdMember {
  final String id;
  final String unitId;
  final String name;
  final String email;
  final String? phone;
  final HouseholdRole role;
  final HouseholdStatus status;
  final DateTime createdAt;

  const HouseholdMember({
    required this.id,
    required this.unitId,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
    required this.createdAt,
  });
}
