import 'package:flutter/material.dart';

class UnitBundle {
  final String propertyId;
  final String unitId;
  final String propertyName;
  final String unitName;
  final String unitType;
  final String occupancyStatus;

  final String tenantName;
  final String tenantEmail;
  final String tenantPhone;

  final String monthlyRent;
  final String currentBalance;

  final List<RentLedgerRow> rentLedger;
  final List<MaintenanceTicketRow> maintenanceTickets;
  final List<ContractorRow> contractors;
  final List<AssignmentHistoryRow> assignmentHistory;

  UnitBundle({
    required this.propertyId,
    required this.unitId,
    required this.propertyName,
    required this.unitName,
    required this.unitType,
    required this.occupancyStatus,
    required this.tenantName,
    required this.tenantEmail,
    required this.tenantPhone,
    required this.monthlyRent,
    required this.currentBalance,
    required this.rentLedger,
    required this.maintenanceTickets,
    required this.contractors,
    required this.assignmentHistory,
  });
}

enum RentStatus { paid, due, late }

extension RentStatusX on RentStatus {
  String get label => switch (this) {
        RentStatus.paid => 'Paid',
        RentStatus.due => 'Due',
        RentStatus.late => 'Late',
      };
}

class RentLedgerRow {
  final String monthLabel;
  final String amount;
  final String dueDate;
  final RentStatus status;

  RentLedgerRow({
    required this.monthLabel,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  RentLedgerRow copyWith({RentStatus? status}) => RentLedgerRow(
        monthLabel: monthLabel,
        amount: amount,
        dueDate: dueDate,
        status: status ?? this.status,
      );
}

enum TicketStatus { newTicket, assigned, inProgress, completed }

extension TicketStatusX on TicketStatus {
  String get label => switch (this) {
        TicketStatus.newTicket => 'New',
        TicketStatus.assigned => 'Assigned',
        TicketStatus.inProgress => 'In progress',
        TicketStatus.completed => 'Completed',
      };

  IconData get icon => switch (this) {
        TicketStatus.newTicket => Icons.fiber_new_outlined,
        TicketStatus.assigned => Icons.assignment_ind_outlined,
        TicketStatus.inProgress => Icons.construction_outlined,
        TicketStatus.completed => Icons.check_circle_outline,
      };
}

class MaintenanceTicketRow {
  final String id;
  final String title;
  final String category;
  final String priority;
  final TicketStatus status;
  final String createdAt;
  final String? assignedTo;

  MaintenanceTicketRow({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.assignedTo,
  });

  MaintenanceTicketRow copyWith({
    TicketStatus? status,
    String? assignedTo,
  }) =>
      MaintenanceTicketRow(
        id: id,
        title: title,
        category: category,
        priority: priority,
        status: status ?? this.status,
        createdAt: createdAt,
        assignedTo: assignedTo,
      );
}

class ContractorRow {
  final String name;
  final String trade;
  final double rating;

  ContractorRow({
    required this.name,
    required this.trade,
    required this.rating,
  });
}

class AssignmentHistoryRow {
  final String title;
  final String contractor;
  final String date;
  final String status;

  AssignmentHistoryRow({
    required this.title,
    required this.contractor,
    required this.date,
    required this.status,
  });
}

class MockUnitData {
  static UnitBundle bundle({required String propertyId, required String unitId}) {
    return UnitBundle(
      propertyId: propertyId,
      unitId: unitId,
      propertyName: 'Property $propertyId',
      unitName: 'Unit $unitId',
      unitType: 'Apartment',
      occupancyStatus: 'Occupied',
      tenantName: 'John Tenant',
      tenantEmail: 'tenant@example.com',
      tenantPhone: '(555) 010-2000',
      monthlyRent: '\$1,850',
      currentBalance: '\$0',
      rentLedger: [
        RentLedgerRow(monthLabel: 'Jan 2026', amount: '\$1,850', dueDate: 'Jan 1', status: RentStatus.due),
        RentLedgerRow(monthLabel: 'Dec 2025', amount: '\$1,850', dueDate: 'Dec 1', status: RentStatus.paid),
        RentLedgerRow(monthLabel: 'Nov 2025', amount: '\$1,850', dueDate: 'Nov 1', status: RentStatus.paid),
      ],
      maintenanceTickets: [
        MaintenanceTicketRow(
          id: 'T-1001',
          title: 'Leaking faucet in kitchen',
          category: 'Plumbing',
          priority: 'High',
          status: TicketStatus.newTicket,
          createdAt: '2 days ago',
          assignedTo: null,
        ),
        MaintenanceTicketRow(
          id: 'T-1002',
          title: 'AC not cooling',
          category: 'HVAC',
          priority: 'Medium',
          status: TicketStatus.assigned,
          createdAt: '1 week ago',
          assignedTo: 'Mike HVAC',
        ),
      ],
      contractors: [
        ContractorRow(name: 'Mike HVAC', trade: 'HVAC', rating: 4.8),
        ContractorRow(name: 'Sara Plumbing', trade: 'Plumbing', rating: 4.7),
        ContractorRow(name: 'Leo Electric', trade: 'Electrical', rating: 4.6),
      ],
      assignmentHistory: [
        AssignmentHistoryRow(title: 'AC not cooling', contractor: 'Mike HVAC', date: 'Jan 10', status: 'Assigned'),
        AssignmentHistoryRow(title: 'Outlet sparks', contractor: 'Leo Electric', date: 'Dec 22', status: 'Completed'),
      ],
    );
  }
}
