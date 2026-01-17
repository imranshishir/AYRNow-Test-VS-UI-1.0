import 'package:flutter/foundation.dart';

@immutable
class RentLineItem {
  final String id;
  final String propertyName;
  final String unitLabel;
  final String tenantName;
  final String monthLabel;
  final double amount;
  final String status; // Due / Paid / Late / Partial
  const RentLineItem({
    required this.id,
    required this.propertyName,
    required this.unitLabel,
    required this.tenantName,
    required this.monthLabel,
    required this.amount,
    required this.status,
  });

  RentLineItem copyWith({String? status}) => RentLineItem(
        id: id,
        propertyName: propertyName,
        unitLabel: unitLabel,
        tenantName: tenantName,
        monthLabel: monthLabel,
        amount: amount,
        status: status ?? this.status,
      );
}

@immutable
class MaintenanceTicket {
  final String id;
  final String propertyName;
  final String unitLabel;
  final String title;
  final String priority; // Low/Med/High
  final String status; // Open/In progress/Completed
  final String createdAge; // "2d"
  final String description;
  final String? assignedContractor;
  const MaintenanceTicket({
    required this.id,
    required this.propertyName,
    required this.unitLabel,
    required this.title,
    required this.priority,
    required this.status,
    required this.createdAge,
    required this.description,
    this.assignedContractor,
  });

  MaintenanceTicket copyWith({String? status, String? assignedContractor}) =>
      MaintenanceTicket(
        id: id,
        propertyName: propertyName,
        unitLabel: unitLabel,
        title: title,
        priority: priority,
        status: status ?? this.status,
        createdAge: createdAge,
        description: description,
        assignedContractor: assignedContractor ?? this.assignedContractor,
      );
}

@immutable
class ContractorVendor {
  final String id;
  final String name;
  final String trade;
  final String phone;
  final double rating;
  const ContractorVendor({
    required this.id,
    required this.name,
    required this.trade,
    required this.phone,
    required this.rating,
  });
}

@immutable
class WorkOrder {
  final String id;
  final String ticketId;
  final String contractorName;
  final String propertyName;
  final String unitLabel;
  final String status; // Scheduled/In progress/Needs approval/Approved
  final String scheduled;
  final double? invoiceAmount;
  const WorkOrder({
    required this.id,
    required this.ticketId,
    required this.contractorName,
    required this.propertyName,
    required this.unitLabel,
    required this.status,
    required this.scheduled,
    this.invoiceAmount,
  });

  WorkOrder copyWith({String? status, double? invoiceAmount}) => WorkOrder(
        id: id,
        ticketId: ticketId,
        contractorName: contractorName,
        propertyName: propertyName,
        unitLabel: unitLabel,
        status: status ?? this.status,
        scheduled: scheduled,
        invoiceAmount: invoiceAmount ?? this.invoiceAmount,
      );
}

class LandlordDemoStore extends ChangeNotifier {
  final List<RentLineItem> rent = [
    const RentLineItem(
      id: 'R-1001',
      propertyName: 'Elm Street Apartments',
      unitLabel: 'Apt 101',
      tenantName: 'Sarah Johnson',
      monthLabel: 'Jan 2026',
      amount: 1450,
      status: 'Due',
    ),
    const RentLineItem(
      id: 'R-1002',
      propertyName: 'Elm Street Apartments',
      unitLabel: 'Apt 103',
      tenantName: 'David Kim',
      monthLabel: 'Jan 2026',
      amount: 1525,
      status: 'Paid',
    ),
    const RentLineItem(
      id: 'R-2001',
      propertyName: 'Riverside Plaza',
      unitLabel: 'Store 01',
      tenantName: 'Corner Mart LLC',
      monthLabel: 'Jan 2026',
      amount: 3200,
      status: 'Paid',
    ),
    const RentLineItem(
      id: 'R-2002',
      propertyName: 'Riverside Plaza',
      unitLabel: 'Store 03',
      tenantName: 'Nail Studio Inc',
      monthLabel: 'Jan 2026',
      amount: 4100,
      status: 'Late',
    ),
  ];

  final List<MaintenanceTicket> tickets = [
    const MaintenanceTicket(
      id: 'MT-7001',
      propertyName: 'Elm Street Apartments',
      unitLabel: 'Apt 101',
      title: 'Leaking faucet',
      priority: 'Med',
      status: 'Open',
      createdAge: '2d',
      description:
          'Kitchen faucet leaking under sink. Tenant reports water pooling.',
    ),
    const MaintenanceTicket(
      id: 'MT-7002',
      propertyName: 'Elm Street Apartments',
      unitLabel: 'Apt 103',
      title: 'AC not cooling',
      priority: 'High',
      status: 'In progress',
      createdAge: '5d',
      description: 'AC runs but does not cool. Tenant uncomfortable at night.',
      assignedContractor: 'CoolAir HVAC',
    ),
  ];

  final List<ContractorVendor> contractors = const [
    ContractorVendor(
        id: 'C-101',
        name: 'CoolAir HVAC',
        trade: 'HVAC',
        phone: '(716) 555-8801',
        rating: 4.7),
    ContractorVendor(
        id: 'C-102',
        name: 'QuickFix Plumbing',
        trade: 'Plumbing',
        phone: '(716) 555-1122',
        rating: 4.6),
    ContractorVendor(
        id: 'C-103',
        name: 'BrightSpark Electric',
        trade: 'Electrical',
        phone: '(716) 555-3322',
        rating: 4.8),
    ContractorVendor(
        id: 'C-104',
        name: 'HandyPro General',
        trade: 'General',
        phone: '(716) 555-7788',
        rating: 4.5),
  ];

  final List<WorkOrder> workOrders = [
    const WorkOrder(
      id: 'WO-9001',
      ticketId: 'MT-7002',
      contractorName: 'CoolAir HVAC',
      propertyName: 'Elm Street Apartments',
      unitLabel: 'Apt 103',
      status: 'In progress',
      scheduled: 'Today 2:00 PM',
      invoiceAmount: 0,
    ),
  ];

  void markRentPaid(String rentId) {
    final idx = rent.indexWhere((r) => r.id == rentId);
    if (idx >= 0) {
      rent[idx] = rent[idx].copyWith(status: 'Paid');
      notifyListeners();
    }
  }

  void sendReminder(String rentId) {
    notifyListeners();
  }

  void createTicket(MaintenanceTicket t) {
    tickets.insert(0, t);
    notifyListeners();
  }

  void assignContractor(String ticketId, String contractorName) {
    final tIdx = tickets.indexWhere((t) => t.id == ticketId);
    if (tIdx >= 0) {
      tickets[tIdx] = tickets[tIdx]
          .copyWith(status: 'In progress', assignedContractor: contractorName);
      workOrders.insert(
        0,
        WorkOrder(
          id: 'WO-${DateTime.now().millisecondsSinceEpoch}',
          ticketId: ticketId,
          contractorName: contractorName,
          propertyName: tickets[tIdx].propertyName,
          unitLabel: tickets[tIdx].unitLabel,
          status: 'Scheduled',
          scheduled: 'Tomorrow 10:00 AM',
          invoiceAmount: null,
        ),
      );
      notifyListeners();
    }
  }

  void completeWorkOrder(String workOrderId, {double? invoiceAmount}) {
    final wIdx = workOrders.indexWhere((w) => w.id == workOrderId);
    if (wIdx >= 0) {
      workOrders[wIdx] = workOrders[wIdx].copyWith(
        status: 'Needs approval',
        invoiceAmount: invoiceAmount ?? workOrders[wIdx].invoiceAmount ?? 0,
      );
      notifyListeners();
    }
  }

  void approveInvoice(String workOrderId) {
    final wIdx = workOrders.indexWhere((w) => w.id == workOrderId);
    if (wIdx >= 0) {
      workOrders[wIdx] = workOrders[wIdx].copyWith(status: 'Approved');
      notifyListeners();
    }
  }
}
