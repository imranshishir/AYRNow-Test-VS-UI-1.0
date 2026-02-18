import '../models/rent.dart';
import '../models/ticket.dart';
import '../models/job.dart';
import '../models/approval.dart';
import '../models/user.dart';
import '../repos/app_repos.dart';
import '../repos/mock_repos.dart';
import '../repos/community_repo.dart';
import '../repos/tenant_transfer_repo.dart';
import '../repos/household_repo.dart';
import '../repos/notifications_repo.dart';
import 'api_client.dart';
import 'dtos/me_dto.dart';
import 'dtos/rent_board_dto.dart';
import 'dtos/ticket_dto.dart';
import 'dtos/notification_dto.dart';
import '../../features/notifications/models/notification_models.dart';

/// API-backed repos. Implements me, rent board, tickets, notifications via HTTP.
/// Other repos delegate to MockRepos for now.
class ApiRepos implements AppRepos {
  ApiRepos(this._client) : _mock = MockRepos();

  final ApiClient _client;
  final MockRepos _mock;
  late final ApiNotificationsRepo notificationsRepo = ApiNotificationsRepo(_client);

  Future<AppUser> getMe() async {
    final json = await _client.getJson('/v1/me');
    return meDtoToModel(MeDto.fromJson(json));
  }

  Future<List<RentItem>> listRentBoard() async {
    final raw = await _client.getJsonRaw('/v1/rent-board');
    final list = _extractList(raw, 'items');
    return list.map((e) => rentBoardItemDtoToModel(RentBoardItemDto.fromJson(e as Map<String, dynamic>))).toList();
  }

  Future<List<MaintenanceTicket>> listTickets() async {
    final raw = await _client.getJsonRaw('/v1/tickets');
    final list = _extractList(raw, 'items');
    return list.map((e) => ticketDtoToModel(TicketDto.fromJson(e as Map<String, dynamic>))).toList();
  }

  List<dynamic> _extractList(dynamic raw, String key) {
    if (raw is List) return raw;
    if (raw is Map<String, dynamic>) {
      final v = raw[key];
      if (v is List) return v;
    }
    return [];
  }

  // Delegate to mock for unimplemented endpoints
  Future<List<ContractorJob>> listJobs() => _mock.listJobs();
  Future<List<EntryApproval>> listApprovals() => _mock.listApprovals();
  Future<bool> simulatePayment({required double amount}) => _mock.simulatePayment(amount: amount);
  CommunityRepo get communityRepo => _mock.communityRepo;
  TenantTransferRepo get tenantTransferRepo => _mock.tenantTransferRepo;
  HouseholdRepo get householdRepo => _mock.householdRepo;
}

class ApiNotificationsRepo implements NotificationsRepo {
  ApiNotificationsRepo(this._client);

  final ApiClient _client;

  @override
  Future<List<AppNotification>> list({bool unreadOnly = false}) async {
    final query = unreadOnly ? {'unreadOnly': 'true'} : null;
    final raw = await _client.getJsonRaw('/v1/notifications', query);
    final list = raw is List ? raw : (raw is Map ? (raw['items'] ?? raw['data']) ?? [] : []);
    final items = list is List ? list : [];
    return items
        .map((e) => notificationDtoToModel(NotificationDto.fromJson(e as Map<String, dynamic>)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<int> unreadCount() async {
    final items = await list(unreadOnly: true);
    return items.length;
  }

  @override
  Future<void> markRead(String id) async {
    await _client.postJson('/v1/notifications/$id/read');
  }

  @override
  Future<void> markAllRead() async {
    try {
      await _client.postJson('/v1/notifications/mark-all-read');
    } catch (_) {
      final items = await list(unreadOnly: true);
      for (final n in items) {
        try {
          await markRead(n.id);
        } catch (_) {}
      }
    }
  }
}
