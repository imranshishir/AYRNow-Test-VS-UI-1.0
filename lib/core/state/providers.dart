import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repos/mock_repos.dart';
import '../models/role.dart';
import '../models/user.dart';
import '../models/rent.dart';
import '../models/ticket.dart';
import '../models/job.dart';
import '../models/approval.dart';
import '../../features/tenant_transfer/models/tenant_transfer_models.dart';

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
