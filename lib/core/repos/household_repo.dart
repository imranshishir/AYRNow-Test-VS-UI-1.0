import '../../features/household/models/household_models.dart';

abstract class HouseholdRepo {
  Future<List<HouseholdMember>> listHouseholdMembers(String unitId);
  Future<HouseholdMember> inviteMember({
    required String unitId,
    required String name,
    required String email,
    required HouseholdRole role,
  });
  Future<void> deactivateMember(String memberId);
}
