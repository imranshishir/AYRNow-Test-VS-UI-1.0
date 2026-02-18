import '../../features/household/models/household_models.dart';

abstract class HouseholdRepo {
  Future<List<HouseholdMember>> listMembers({required String unitId});
  Future<HouseholdMember> inviteMember({
    required String unitId,
    required String name,
    required String email,
    String? phone,
    required HouseholdRole role,
  });
  Future<void> deactivateMember({required String memberId});
}
