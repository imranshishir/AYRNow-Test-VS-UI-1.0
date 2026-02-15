import 'package:cloud_firestore/cloud_firestore.dart';

/// Lease doc at accounts/{accountId}/leases/{leaseId}.
class Lease {
  final String id;
  final String propertyId;
  final String unitId;
  final String primaryTenantUid;
  final List<String> tenantUids;
  final String status; // active | ended | pending
  final DateTime startDate;
  final DateTime? endDate;
  final num rentAmount;
  final DateTime createdAt;

  const Lease({
    required this.id,
    required this.propertyId,
    required this.unitId,
    required this.primaryTenantUid,
    required this.tenantUids,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.rentAmount,
    required this.createdAt,
  });

  factory Lease.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    final uids = d['tenantUids'];
    final List<String> list = uids is List
        ? (uids).map((e) => e.toString()).toList()
        : <String>[];
    return Lease(
      id: doc.id,
      propertyId: d['propertyId'] as String? ?? '',
      unitId: d['unitId'] as String? ?? '',
      primaryTenantUid: d['primaryTenantUid'] as String? ?? '',
      tenantUids: list,
      status: d['status'] as String? ?? 'pending',
      startDate:
          (d['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (d['endDate'] as Timestamp?)?.toDate(),
      rentAmount: (d['rentAmount'] as num?) ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'unitId': unitId,
      'primaryTenantUid': primaryTenantUid,
      'tenantUids': tenantUids,
      'status': status,
      'startDate': Timestamp.fromDate(startDate),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      'rentAmount': rentAmount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isActive => status == 'active';
}
