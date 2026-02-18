import 'package:flutter/foundation.dart';

/// Portable tenant profile for transfer requests.
@immutable
class TenantProfile {
  final String id;
  final String tenantId;
  final String fullName;
  final String phone;
  final String email;
  final String currentAddress;
  final List<OccupancyRecord> occupancyHistory;
  final int paymentScore; // 0-100
  final List<TenantReview> reviews;
  final List<ProfileDocument> documents;
  final DateTime createdAt;

  const TenantProfile({
    required this.id,
    required this.tenantId,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.currentAddress,
    required this.occupancyHistory,
    required this.paymentScore,
    required this.reviews,
    required this.documents,
    required this.createdAt,
  });
}

/// Past or current occupancy at a property.
@immutable
class OccupancyRecord {
  final String propertyName;
  final String unitLabel;
  final DateTime startDate;
  final DateTime? endDate;
  final String? landlordName;

  const OccupancyRecord({
    required this.propertyName,
    required this.unitLabel,
    required this.startDate,
    this.endDate,
    this.landlordName,
  });
}

/// Review from a past landlord.
@immutable
class TenantReview {
  final String id;
  final String reviewerName;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;

  const TenantReview({
    required this.id,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

/// Placeholder document metadata; no uploads in v1.
@immutable
class ProfileDocument {
  final String id;
  final String type; // "ID", "Paystub", "Lease", "Other"
  final String filename;
  final String status; // "missing" | "uploaded" | "verified"

  const ProfileDocument({
    required this.id,
    required this.type,
    required this.filename,
    required this.status,
  });
}

/// Transfer request status.
enum TransferRequestStatus {
  pending,
  accepted,
  rejected;

  String get label => switch (this) {
        TransferRequestStatus.pending => 'Pending',
        TransferRequestStatus.accepted => 'Accepted',
        TransferRequestStatus.rejected => 'Rejected',
      };
}

/// Tenant's request to transfer profile to a new landlord.
@immutable
class TransferRequest {
  final String id;
  final String tenantId;
  final String tenantName;
  final String targetEmailOrCode;
  final String note;
  final TransferRequestStatus status;
  final DateTime createdAt;
  final DateTime? decidedAt;
  final String? landlordMessage;

  const TransferRequest({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.targetEmailOrCode,
    required this.note,
    required this.status,
    required this.createdAt,
    this.decidedAt,
    this.landlordMessage,
  });

  bool get isActive => status == TransferRequestStatus.pending;
}
