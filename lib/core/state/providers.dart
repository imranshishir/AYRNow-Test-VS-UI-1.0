import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repos/mock_repos.dart';
import '../models/role.dart';
import '../models/user.dart';
import '../models/rent.dart';
import '../models/ticket.dart';
import '../models/job.dart';
import '../models/approval.dart';

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
