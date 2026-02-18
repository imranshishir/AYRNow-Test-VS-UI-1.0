// Backend-ready request/response contracts for household features.
// No networking - types only for future REST alignment.

class InviteHouseholdMemberRequest {
  final String unitId;
  final String name;
  final String email;
  final String? phone;
  final String role;

  const InviteHouseholdMemberRequest({
    required this.unitId,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
  });
}

class HouseholdMemberResponse {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String role;
  final bool isActive;

  const HouseholdMemberResponse({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    this.isActive = true,
  });
}
