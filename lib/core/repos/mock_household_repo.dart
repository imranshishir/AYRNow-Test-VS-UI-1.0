import '../../features/household/models/household_models.dart';
import 'household_repo.dart';

class MockHouseholdRepo implements HouseholdRepo {
  static const _demoUnitId = 'unit-1';

  final List<HouseholdMember> _members = [];

  MockHouseholdRepo() {
    _members.addAll([
      HouseholdMember(
        id: 'm1',
        unitId: _demoUnitId,
        name: 'A. Johnson',
        email: 'a.johnson@example.com',
        phone: '+1 555-0100',
        role: HouseholdRole.primaryTenant,
        status: HouseholdStatus.active,
        createdAt: DateTime(2024, 1, 15),
      ),
      HouseholdMember(
        id: 'm2',
        unitId: _demoUnitId,
        name: 'J. Johnson',
        email: 'j.johnson@example.com',
        phone: null,
        role: HouseholdRole.familyMember,
        status: HouseholdStatus.active,
        createdAt: DateTime(2024, 2, 1),
      ),
    ]);
  }

  @override
  Future<List<HouseholdMember>> listHouseholdMembers(String unitId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _members.where((m) => m.unitId == unitId).toList();
  }

  @override
  Future<HouseholdMember> inviteMember({
    required String unitId,
    required String name,
    required String email,
    required HouseholdRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final member = HouseholdMember(
      id: 'm${DateTime.now().millisecondsSinceEpoch}',
      unitId: unitId,
      name: name.trim(),
      email: email.trim(),
      phone: null,
      role: role,
      status: HouseholdStatus.invited,
      createdAt: DateTime.now(),
    );
    _members.insert(0, member);
    return member;
  }

  @override
  Future<void> deactivateMember(String memberId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _members.indexWhere((m) => m.id == memberId);
    if (idx < 0) return;
    final old = _members[idx];
    _members[idx] = HouseholdMember(
      id: old.id,
      unitId: old.unitId,
      name: old.name,
      email: old.email,
      phone: old.phone,
      role: old.role,
      status: HouseholdStatus.inactive,
      createdAt: old.createdAt,
    );
  }
}
