import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repos/mock_repos.dart';
import '../models/role.dart';
import '../models/user.dart';
import '../models/rent.dart';
import '../models/ticket.dart';
import '../models/job.dart';
import '../models/approval.dart';
import '../../features/notifications/models/notification_models.dart';

final reposProvider = Provider<MockRepos>((ref) => MockRepos());

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

  Future<void> add(AppNotification n) async {
    await _ref.read(reposProvider).notificationsRepo.add(n);
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(notificationsUnreadCountProvider);
  }
}

final notificationsControllerProvider = Provider<NotificationsController>((ref) {
  return NotificationsController(ref);
});

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
