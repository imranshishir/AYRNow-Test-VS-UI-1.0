import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../auth/auth_storage.dart';
import '../backend/api_base_url.dart';
import '../repos/mock_repos.dart';
import '../models/role.dart';
import '../models/user.dart';
import '../models/rent.dart';
import '../models/ticket.dart';
import '../models/job.dart';
import '../models/approval.dart';
import '../backend/dtos/property_dto.dart';
import '../../features/community/models/community_models.dart';
import '../../features/tenant_transfer/models/tenant_transfer_models.dart';
import '../../features/household/models/household_models.dart';

final reposProvider = Provider<MockRepos>((ref) => MockRepos());

final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());

/// Token read from secure storage once at startup. Use for initial session restore.
final bootTokenProvider = FutureProvider<String?>((ref) async {
  return ref.read(authStorageProvider).readToken();
});

/// Resolves once at startup: restores token from storage, validates with GET /api/v1/me.
/// Returns [AppUser] if valid, null otherwise (and clears storage on failure).
final initialSessionProvider = FutureProvider<AppUser?>((ref) async {
  final token = await ref.watch(bootTokenProvider.future);
  if (token == null || token.isEmpty) return null;
  try {
    final baseUrl = await resolveApiBaseUrl();
    final r = await http.get(
      Uri.parse('$baseUrl/v1/me'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 10));
    if (r.statusCode >= 200 && r.statusCode < 300) {
      final d = jsonDecode(r.body) as Map<String, dynamic>?;
      final id = (d?['userId'] ?? d?['id'])?.toString() ?? '';
      final userInfo = d?['user'] as Map<String, dynamic>?;
      final name = userInfo?['displayName'] as String? ?? userInfo?['name'] as String? ?? (d?['name'] as String?) ?? (userInfo?['email'] as String?)?.split('@').first ?? (d?['email'] as String?)?.split('@').first ?? '';
      final roleStr = d?['role'] as String? ?? userInfo?['role'] as String? ?? 'tenant';
      final role = UserRole.values.asNameMap()[roleStr] ?? UserRole.tenant;
      ref.read(authTokenProvider.notifier).state = token;
      ref.read(currentUserProvider.notifier).state = AppUser(id: id, name: name, role: role);
      return AppUser(id: id, name: name, role: role);
    }
  } catch (_) {}
  await ref.read(authStorageProvider).clearToken();
  ref.read(authTokenProvider.notifier).state = null;
  return null;
});

/// In-memory token for API calls. Set after login or after boot validation; cleared on logout.
/// ApiClient/tokenGetter should read this (not storage) to avoid per-request I/O.
final authTokenProvider = StateProvider<String?>((_) => null);

/// Controller for login (API + persist) and logout (clear storage and state).
final authControllerProvider = Provider<AuthController>((ref) => AuthController(ref));

class AuthController {
  AuthController(this._ref);
  final Ref _ref;

  /// Calls POST /api/v1/auth/login with email and password; saves token; sets authTokenProvider and currentUserProvider.
  /// Returns (token, user) on success; null on failure. Role comes from backend response.
  Future<({String token, AppUser user})?> login({
    required String email,
    required String password,
    String? name,
  }) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri = Uri.parse('$baseUrl/v1/auth/login');
    final body = <String, dynamic>{
      'email': email,
      'password': password,
    };
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 401) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) return null;
    Map<String, dynamic>? data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
    final token = data?['accessToken'] as String? ?? data?['token'] as String?;
    final userId = (data?['userId'] ?? data?['id'])?.toString() ?? '';
    if (token == null || token.isEmpty) return null;
    await _ref.read(authStorageProvider).writeToken(token);
    _ref.read(authTokenProvider.notifier).state = token;
    final roleStr = data?['role'] as String? ?? 'tenant';
    final role = UserRole.values.asNameMap()[roleStr] ?? UserRole.tenant;
    final displayName = (name != null && name.isNotEmpty)
        ? name
        : (data?['email'] as String? ?? email).split('@').first;
    final user = AppUser(id: userId, name: displayName, role: role);
    _ref.read(currentUserProvider.notifier).state = user;
    return (token: token, user: user);
  }

  /// Clears secure storage, in-memory token, and current user; invalidates session. Caller should navigate to '/'.
  Future<void> logout() async {
    await _ref.read(authStorageProvider).clearToken();
    _ref.read(authTokenProvider.notifier).state = null;
    _ref.read(currentUserProvider.notifier).state = const AppUser(id: '', name: '', role: UserRole.tenant);
    _ref.invalidate(initialSessionProvider);
  }
}

/// Set by initialSessionProvider (restore) or AuthController.login. Cleared on logout.
final currentUserProvider = StateProvider<AppUser>((ref) {
  return const AppUser(id: '', name: '', role: UserRole.tenant);
});

/// Increment to trigger refresh of landlord property list (e.g. after adding a property).
final landlordPropertiesRefreshProvider = StateProvider<int>((ref) => 0);

/// Landlord properties from GET /v1/properties. Refreshes when landlordPropertiesRefreshProvider changes.
final landlordPropertiesProvider = FutureProvider<List<PropertyDto>>((ref) async {
  ref.watch(landlordPropertiesRefreshProvider);
  final token = ref.watch(authTokenProvider);
  if (token == null || token.isEmpty) return [];
  final baseUrl = await resolveApiBaseUrl();
  final r = await http.get(
    Uri.parse('$baseUrl/v1/properties'),
    headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
  ).timeout(const Duration(seconds: 15));
  if (r.statusCode != 200) return [];
  final list = jsonDecode(r.body);
  if (list is! List) return [];
  return list
      .map((e) => e is Map ? PropertyDto(
        id: (e['id'] ?? '').toString(),
        accountId: (e['accountId'] ?? '').toString(),
        name: (e['name'] as String?) ?? '',
        address1: e['address'] as String?,
      ) : null)
      .whereType<PropertyDto>()
      .toList();
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
final communityPostsProvider = FutureProvider.family<List<CommunityPost>,
    ({String role, String? scopeFilter})>((ref, params) async {
  return ref
      .watch(reposProvider)
      .communityRepo
      .listPosts(role: params.role, scopeFilter: params.scopeFilter);
});

/// Comments for a post.
final communityCommentsProvider =
    FutureProvider.family<List<CommunityComment>, String>((ref, postId) async {
  return ref.watch(reposProvider).communityRepo.listComments(postId);
});

// Tenant Transfer (portable profile + transfer requests)
final tenantProfileProvider = FutureProvider<TenantProfile>((ref) async {
  return ref.watch(reposProvider).tenantTransferRepo.getMyTenantProfile();
});

final myTransferRequestProvider = FutureProvider<TransferRequest?>((ref) async {
  return ref
      .watch(reposProvider)
      .tenantTransferRepo
      .getMyActiveTransferRequest();
});

final landlordTransferInboxProvider =
    FutureProvider.family<List<TransferRequest>, String?>((ref, status) async {
  return ref
      .watch(reposProvider)
      .tenantTransferRepo
      .listTransferRequestsForLandlord(status: status);
});

/// Invalidate these after create/decide so UI refreshes.
final transferRequestControllerProvider =
    Provider<TransferRequestController>((ref) {
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
    final req = await repo.createTransferRequest(
        targetEmailOrCode: targetEmailOrCode, note: note);
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
final householdMembersProvider =
    FutureProvider.family<List<HouseholdMember>, String>((ref, unitId) async {
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
