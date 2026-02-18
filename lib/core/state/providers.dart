import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repos/mock_repos.dart';
import '../repos/app_repos.dart';
import '../backend/api_client.dart';
import '../backend/api_config.dart';
import '../models/role.dart';
import '../models/user.dart';
import '../models/rent.dart';
import '../models/ticket.dart';
import '../models/job.dart';
import '../models/approval.dart';
import '../../features/community/models/community_models.dart';
import '../../features/tenant_transfer/models/tenant_transfer_models.dart';
import '../../features/household/models/household_models.dart';
import '../../features/notifications/models/notification_models.dart';
import 'backend_flags.dart';

import '../backend/api_repos.dart' as api;

final reposProvider = Provider<AppRepos>((ref) {
  final useApi = ref.watch(useApiBackendProvider);
  if (useApi) {
    return api.ApiRepos(ApiClient(baseUrl: apiBaseUrl));
  }
  return MockRepos();
});

final currentUserProvider = StateProvider<AppUser>((ref) {
  return const AppUser(id: 'u1', name: 'Demo User', role: UserRole.landlord);
});

/// When useApiBackend is true, fetches /v1/me. Non-blocking; errors surface via AsyncValue.
final meProvider = FutureProvider<AppUser>((ref) async {
  final useApi = ref.watch(useApiBackendProvider);
  if (!useApi) return ref.read(currentUserProvider);
  final repos = ref.read(reposProvider);
  if (repos is api.ApiRepos) return repos.getMe();
  return ref.read(currentUserProvider);
});

/// Session user: uses me when API backend, else currentUserProvider. Use when API may be on.
final sessionUserProvider = Provider<AppUser>((ref) {
  final useApi = ref.watch(useApiBackendProvider);
  if (!useApi) return ref.watch(currentUserProvider);
  return ref.watch(meProvider).valueOrNull ?? ref.read(currentUserProvider);
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

final notificationsProvider = FutureProvider.family<List<AppNotification>, bool>((ref, unreadOnly) async {
  return ref.watch(reposProvider).notificationsRepo.list(unreadOnly: unreadOnly);
});

final notificationsUnreadCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(reposProvider).notificationsRepo.unreadCount();
});

class NotificationsController {
  NotificationsController(this._ref);

  final Ref _ref;

  Future<void> markRead(String id) async {
    await _ref.read(reposProvider).notificationsRepo.markRead(id);
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(notificationsUnreadCountProvider);
  }

  Future<void> markAllRead() async {
    await _ref.read(reposProvider).notificationsRepo.markAllRead();
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(notificationsUnreadCountProvider);
  }
}

final notificationsControllerProvider = Provider<NotificationsController>((ref) {
  return NotificationsController(ref);
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

// Tenant Transfer (portable profile + transfer requests)
final tenantProfileProvider = FutureProvider<TenantProfile>((ref) async {
  return ref.watch(reposProvider).tenantTransferRepo.getMyTenantProfile();
});

final myTransferRequestProvider = FutureProvider<TransferRequest?>((ref) async {
  return ref.watch(reposProvider).tenantTransferRepo.getMyActiveTransferRequest();
});

final landlordTransferInboxProvider = FutureProvider.family<List<TransferRequest>, String?>((ref, status) async {
  return ref.watch(reposProvider).tenantTransferRepo.listTransferRequestsForLandlord(status: status);
});

/// Invalidate these after create/decide so UI refreshes.
final transferRequestControllerProvider = Provider<TransferRequestController>((ref) {
  return TransferRequestController(ref);
});

class TransferRequestController {
  final Ref _ref;

  TransferRequestController(this._ref);

  Future<TransferRequest> createTransferRequest({
    required String targetEmailOrCode,
    required String note,
  }) async {
    final repo = _ref.read(reposProvider).tenantTransferRepo;
    final req = await repo.createTransferRequest(targetEmailOrCode: targetEmailOrCode, note: note);
    _ref.invalidate(myTransferRequestProvider);
    _ref.invalidate(landlordTransferInboxProvider);
    return req;
  }

  Future<TransferRequest> decideTransferRequest({
    required String requestId,
    required bool accept,
    String? landlordMessage,
  }) async {
    final repo = _ref.read(reposProvider).tenantTransferRepo;
    final req = await repo.decideTransferRequest(
      requestId: requestId,
      accept: accept,
      landlordMessage: landlordMessage,
    );
    _ref.invalidate(myTransferRequestProvider);
    _ref.invalidate(landlordTransferInboxProvider);
    return req;
  }
}

// Household (family roles)
final householdMembersProvider = FutureProvider.family<List<HouseholdMember>, String>((ref, unitId) async {
  return ref.watch(reposProvider).householdRepo.listMembers(unitId: unitId);
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
    String? phone,
    required HouseholdRole role,
  }) async {
    final repo = _ref.read(reposProvider).householdRepo;
    final member = await repo.inviteMember(
      unitId: unitId,
      name: name,
      email: email,
      phone: phone,
      role: role,
    );
    _ref.invalidate(householdMembersProvider);
    return member;
  }

  Future<void> deactivateMember(String memberId) async {
    final repo = _ref.read(reposProvider).householdRepo;
    await repo.deactivateMember(memberId: memberId);
    _ref.invalidate(householdMembersProvider);
  }
}
