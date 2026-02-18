import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repos/mock_repos.dart';
import '../models/role.dart';
import '../models/user.dart';
import '../models/rent.dart';
import '../models/ticket.dart';
import '../models/job.dart';
import '../models/approval.dart';
import '../../features/community/models/community_models.dart';

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

/// Community posts. [scopeFilter] null = all, 'property' or 'unit' to filter.
final communityPostsProvider = FutureProvider.family<List<CommunityPost>, ({String role, String? scopeFilter})>((ref, params) async {
  return ref.watch(reposProvider).communityRepo.listPosts(role: params.role, scopeFilter: params.scopeFilter);
});

/// Comments for a post.
final communityCommentsProvider = FutureProvider.family<List<CommunityComment>, String>((ref, postId) async {
  return ref.watch(reposProvider).communityRepo.listComments(postId);
});
