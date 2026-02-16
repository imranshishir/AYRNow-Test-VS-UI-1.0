import 'package:cloud_firestore/cloud_firestore.dart';

/// Unit doc at accounts/{accountId}/properties/{propertyId}/units/{unitId}.
class Unit {
  final String id;
  final String unitLabel;
  final num rentAmount;
  final String status;
  final DateTime createdAt;

  const Unit({
    required this.id,
    required this.unitLabel,
    required this.rentAmount,
    required this.status,
    required this.createdAt,
  });

  factory Unit.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Unit(
      id: doc.id,
      unitLabel: d['unitLabel'] as String? ?? '',
      rentAmount: (d['rentAmount'] as num?) ?? 0,
      status: d['status'] as String? ?? 'vacant',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unitLabel': unitLabel,
      'rentAmount': rentAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
