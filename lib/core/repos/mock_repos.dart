import 'dart:math';
import '../models/rent.dart';
import '../models/ticket.dart';
import '../models/job.dart';
import '../models/approval.dart';

class MockRepos {
  final _rng = Random(7);

  Future<List<RentItem>> listRentBoard() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return [
      RentItem(tenantName: 'A. Johnson', unit: 'Unit 1A', amountDue: 1650, dueDate: DateTime.now().add(const Duration(days: 2)), status: 'Pending'),
      RentItem(tenantName: 'S. Ahmed', unit: 'Unit 2B', amountDue: 1450, dueDate: DateTime.now().subtract(const Duration(days: 3)), status: 'Late'),
      RentItem(tenantName: 'M. Chen', unit: 'Unit 3C', amountDue: 1750, dueDate: DateTime.now().subtract(const Duration(days: 1)), status: 'Partial'),
      RentItem(tenantName: 'R. Patel', unit: 'Unit 4D', amountDue: 1580, dueDate: DateTime.now().subtract(const Duration(days: 5)), status: 'Paid'),
    ];
  }

  Future<List<MaintenanceTicket>> listTickets() async {
    await Future.delayed(const Duration(milliseconds: 420));
    return [
      MaintenanceTicket(id: 'TCK-1007', unit: 'Unit 2B', title: 'Leaking sink', priority: 'High', createdAt: DateTime.now().subtract(const Duration(hours: 20)), status: 'Open'),
      MaintenanceTicket(id: 'TCK-1008', unit: 'Unit 1A', title: 'AC not cooling', priority: 'Med', createdAt: DateTime.now().subtract(const Duration(days: 2)), status: 'Approved'),
      MaintenanceTicket(id: 'TCK-1009', unit: 'Unit 3C', title: 'Broken window latch', priority: 'Low', createdAt: DateTime.now().subtract(const Duration(days: 5)), status: 'Assigned'),
    ];
  }

  Future<List<ContractorJob>> listJobs() async {
    await Future.delayed(const Duration(milliseconds: 380));
    return [
      ContractorJob(id: 'JOB-501', property: 'Harlem Rd Apartments', issue: 'Replace faucet', distanceText: '3.2 mi', status: 'Invited'),
      ContractorJob(id: 'JOB-502', property: 'Downtown Lofts', issue: 'Drywall patch', distanceText: '5.9 mi', status: 'InProgress'),
      ContractorJob(id: 'JOB-503', property: 'Elmwood Plaza', issue: 'Storefront lock repair', distanceText: '7.4 mi', status: 'AwaitingApproval'),
    ];
  }

  Future<List<EntryApproval>> listApprovals() async {
    await Future.delayed(const Duration(milliseconds: 320));
    final now = DateTime.now();
    return [
      EntryApproval(id: 'APR-201', visitorName: 'Contractor: Mike', unit: 'Unit 2B', windowStart: now.add(const Duration(minutes: 10)), windowEnd: now.add(const Duration(hours: 1)), reason: 'Plumbing repair'),
      EntryApproval(id: 'APR-202', visitorName: 'Delivery: UPS', unit: 'Unit 1A', windowStart: now.add(const Duration(minutes: 30)), windowEnd: now.add(const Duration(hours: 2)), reason: 'Package drop-off'),
    ];
  }

  Future<bool> simulatePayment({required double amount}) async {
    await Future.delayed(const Duration(milliseconds: 650));
    return _rng.nextDouble() > 0.10; // 10% fail
  }
}
