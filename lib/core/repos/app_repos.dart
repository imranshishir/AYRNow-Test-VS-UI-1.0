import '../models/rent.dart';
import '../models/ticket.dart';
import '../models/job.dart';
import '../models/approval.dart';
import 'community_repo.dart';
import 'tenant_transfer_repo.dart';
import 'household_repo.dart';
import 'notifications_repo.dart';

/// Common surface for data access. Implemented by MockRepos and ApiRepos.
abstract class AppRepos {
  Future<List<RentItem>> listRentBoard();
  Future<List<MaintenanceTicket>> listTickets();
  Future<List<ContractorJob>> listJobs();
  Future<List<EntryApproval>> listApprovals();
  NotificationsRepo get notificationsRepo;
  CommunityRepo get communityRepo;
  TenantTransferRepo get tenantTransferRepo;
  HouseholdRepo get householdRepo;
  Future<bool> simulatePayment({required double amount});
}
