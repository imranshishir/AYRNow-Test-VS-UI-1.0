import 'package:cloud_firestore/cloud_firestore.dart';

/// Property doc at accounts/{accountId}/properties/{propertyId}.
class Property {
  final String id;
  final String name;
  final String? address;
  final DateTime createdAt;
  final String status;

  const Property({
    required this.id,
    required this.name,
    this.address,
    required this.createdAt,
    required this.status,
  });

  factory Property.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Property(
      id: doc.id,
      name: d['name'] as String? ?? '',
      address: d['address'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: d['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (address != null) 'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }
}
