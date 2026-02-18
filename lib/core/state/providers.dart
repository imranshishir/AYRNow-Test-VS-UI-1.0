import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repos/mock_repos.dart';
import '../models/role.dart';
import '../models/user.dart';
import '../models/rent.dart';
import '../models/ticket.dart';
import '../models/job.dart';
import '../models/approval.dart';
import '../../features/household/models/household_models.dart';

final reposProvider = Provider<MockRepos>((ref) => MockRepos());

final currentUserProvider = StateProvider<AppUser>((ref) {
  return const AppUser(id: 'u1', name: 'Demo User', role: UserRole.landlord);
});

final rentBoardProvider = FutureProvider<List<RentItem>>((ref) async {
  return ref.watch(reposProvider).listRentBoard();
});

final ticketsProvider = FutureProvider<List<MaintenanceTicket>>((ref) async {
  return ref.watch(reposProvider).listTickets();
});

final jobsProvider = FutureProvider<List<ContractorJob>>((ref) async {
  return ref.watch(reposProvider).listJobs();
});

final approvalsProvider = FutureProvider<List<EntryApproval>>((ref) async {
  return ref.watch(reposProvider).listApprovals();
});

final tenantAmountDueProvider = StateProvider<double>((ref) => 1650.00);

// Household (family roles)
final householdMembersProvider = FutureProvider.family<List<HouseholdMember>, String>((ref, unitId) async {
  return ref.watch(reposProvider).householdRepo.listHouseholdMembers(unitId);
});

final householdControllerProvider = Provider<HouseholdController>((ref) {
  return HouseholdController(ref);
});

class HouseholdController {
  final Ref _ref;

  HouseholdController(this._ref);

  Future<HouseholdMember> inviteMember({
    required String unitId,
    required String name,
    required String email,
    required HouseholdRole role,
  }) async {
    final repo = _ref.read(reposProvider).householdRepo;
    final member = await repo.inviteMember(unitId: unitId, name: name, email: email, role: role);
    _ref.invalidate(householdMembersProvider);
    return member;
  }

  Future<void> deactivateMember(String memberId) async {
    final repo = _ref.read(reposProvider).householdRepo;
    await repo.deactivateMember(memberId);
    _ref.invalidate(householdMembersProvider);
  }
}
