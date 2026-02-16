import 'package:flutter/foundation.dart';

enum VisitorType { guest, delivery, vendor }

@immutable
class GuardApproval {
  final String id;
  final String visitorName;
  final VisitorType type;
  final String unitLabel; // Apt/Store
  final String propertyName;
  final DateTime requestedAt;
  final String notes;

  const GuardApproval({
    required this.id,
    required this.visitorName,
    required this.type,
    required this.unitLabel,
    required this.propertyName,
    required this.requestedAt,
    required this.notes,
  });
}

@immutable
class ActiveVisitor {
  final String id;
  final String visitorName;
  final VisitorType type;
  final String unitLabel;
  final String propertyName;
  final DateTime checkInAt;
  final String passCode; // QR/OTP placeholder
  final String? vehiclePlate;
  final int partySize;

  const ActiveVisitor({
    required this.id,
    required this.visitorName,
    required this.type,
    required this.unitLabel,
    required this.propertyName,
    required this.checkInAt,
    required this.passCode,
    required this.vehiclePlate,
    required this.partySize,
  });

  ActiveVisitor copyWith({
    String? passCode,
    String? vehiclePlate,
    int? partySize,
  }) {
    return ActiveVisitor(
      id: id,
      visitorName: visitorName,
      type: type,
      unitLabel: unitLabel,
      propertyName: propertyName,
      checkInAt: checkInAt,
      passCode: passCode ?? this.passCode,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      partySize: partySize ?? this.partySize,
    );
  }
}

@immutable
class IncidentReport {
  final String id;
  final String propertyName;
  final String unitLabel;
  final String category;
  final String description;
  final DateTime createdAt;

  const IncidentReport({
    required this.id,
    required this.propertyName,
    required this.unitLabel,
    required this.category,
    required this.description,
    required this.createdAt,
  });
}

class GuardDemoStore extends ChangeNotifier {
  // Seed approvals (pretend they came from tenant/landlord app)
  final List<GuardApproval> approvals = [
    GuardApproval(
      id: 'AP-1001',
      visitorName: 'John Guest',
      type: VisitorType.guest,
      unitLabel: 'Apt 3B',
      propertyName: 'Harlem Gardens',
      requestedAt: DateTime.now().subtract(const Duration(minutes: 18)),
      notes: 'Visiting for dinner',
    ),
    GuardApproval(
      id: 'AP-1002',
      visitorName: 'FedEx Delivery',
      type: VisitorType.delivery,
      unitLabel: 'Apt 12A',
      propertyName: 'Harlem Gardens',
      requestedAt: DateTime.now().subtract(const Duration(minutes: 9)),
      notes: 'Signature required',
    ),
    GuardApproval(
      id: 'AP-1003',
      visitorName: 'HVAC Vendor',
      type: VisitorType.vendor,
      unitLabel: 'Store 14',
      propertyName: 'Broadway Plaza',
      requestedAt: DateTime.now().subtract(const Duration(minutes: 32)),
      notes: 'Work order #WO-7781',
    ),
  ];

  final List<ActiveVisitor> active = [];
  final List<IncidentReport> incidents = [];

  void denyApproval(String id) {
    approvals.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  ActiveVisitor checkInFromApproval({
    required GuardApproval approval,
    required String passCode,
    required int partySize,
    String? vehiclePlate,
  }) {
    final v = ActiveVisitor(
      id: 'AV-${DateTime.now().millisecondsSinceEpoch}',
      visitorName: approval.visitorName,
      type: approval.type,
      unitLabel: approval.unitLabel,
      propertyName: approval.propertyName,
      checkInAt: DateTime.now(),
      passCode: passCode,
      vehiclePlate: vehiclePlate,
      partySize: partySize,
    );
    approvals.removeWhere((a) => a.id == approval.id);
    active.insert(0, v);
    notifyListeners();
    return v;
  }

  void checkOut(String activeId) {
    active.removeWhere((v) => v.id == activeId);
    notifyListeners();
  }

  void addIncident({
    required String propertyName,
    required String unitLabel,
    required String category,
    required String description,
  }) {
    incidents.insert(
      0,
      IncidentReport(
        id: 'IR-${DateTime.now().millisecondsSinceEpoch}',
        propertyName: propertyName,
        unitLabel: unitLabel,
        category: category,
        description: description,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
