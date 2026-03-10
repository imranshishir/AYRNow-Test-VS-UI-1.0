import 'package:flutter/foundation.dart';

/// High-level lease packet returned from /api/v1/lease-onboarding/packets endpoints.
@immutable
class LeasePacket {
  final String id;
  final String unitId;
  final String tenantName;
  final String tenantContact;
  final DateTime? leaseStartDate;
  final DateTime? leaseEndDate;
  final double? monthlyRent;
  final double? securityDeposit;
  final int? leaseTermMonths;
  final String? utilitiesResponsibility;
  final bool? petsAllowed;
  final String? specialNotes;
  final int? rentDueDay;
  final String? lateFeeClause;
  final List<TenantDocumentRequirement> documentRequirements;
  final List<InviteOnboardingStatus> inviteSteps;
  final String status;
  final String? inviteId;
  final String? inviteUrlToken;
  final String? tenantTypedName;

  const LeasePacket({
    required this.id,
    required this.unitId,
    required this.tenantName,
    required this.tenantContact,
    required this.leaseStartDate,
    required this.leaseEndDate,
    required this.monthlyRent,
    required this.securityDeposit,
    required this.leaseTermMonths,
    required this.utilitiesResponsibility,
    required this.petsAllowed,
    required this.specialNotes,
    required this.rentDueDay,
    required this.lateFeeClause,
    required this.documentRequirements,
    required this.inviteSteps,
    required this.status,
    required this.inviteId,
    required this.inviteUrlToken,
    required this.tenantTypedName,
  });

  factory LeasePacket.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    double? parseNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final docsJson = json['documentRequirements'];
    final stepsJson = json['inviteSteps'];

    return LeasePacket(
      id: json['id']?.toString() ?? '',
      unitId: json['unitId']?.toString() ?? '',
      tenantName: json['tenantName']?.toString() ?? '',
      tenantContact: json['tenantContact']?.toString() ?? '',
      leaseStartDate: parseDate(json['leaseStartDate']),
      leaseEndDate: parseDate(json['leaseEndDate']),
      monthlyRent: parseNum(json['monthlyRent']),
      securityDeposit: parseNum(json['securityDeposit']),
      leaseTermMonths: json['leaseTermMonths'] as int?,
      utilitiesResponsibility: json['utilitiesResponsibility']?.toString(),
      petsAllowed: json['petsAllowed'] as bool?,
      specialNotes: json['specialNotes']?.toString(),
      rentDueDay: json['rentDueDay'] as int?,
      lateFeeClause: json['lateFeeClause']?.toString(),
      documentRequirements: docsJson is List
          ? docsJson
              .whereType<Map>()
              .map((e) => TenantDocumentRequirement.fromJson(
                    e.cast<String, dynamic>(),
                  ))
              .toList()
          : const <TenantDocumentRequirement>[],
      inviteSteps: stepsJson is List
          ? stepsJson
              .whereType<Map>()
              .map((e) => InviteOnboardingStatus.fromJson(
                    e.cast<String, dynamic>(),
                  ))
              .toList()
          : const <InviteOnboardingStatus>[],
      status: json['status']?.toString() ?? '',
      inviteId: json['inviteId']?.toString(),
      inviteUrlToken: json['inviteUrlToken']?.toString(),
      tenantTypedName: json['tenantTypedName']?.toString(),
    );
  }

  LeasePacketSuggestion get suggestion => LeasePacketSuggestion(
        leaseEndDate: leaseEndDate,
        rentDueDay: rentDueDay,
        lateFeeClause: lateFeeClause,
        documentRequirements: documentRequirements,
      );

  bool get isDraftLike =>
      status == 'draft' || status == 'suggested' || status == 'sent';
}

/// Lightweight view of suggested values derived from the packet.
@immutable
class LeasePacketSuggestion {
  final DateTime? leaseEndDate;
  final int? rentDueDay;
  final String? lateFeeClause;
  final List<TenantDocumentRequirement> documentRequirements;

  const LeasePacketSuggestion({
    required this.leaseEndDate,
    required this.rentDueDay,
    required this.lateFeeClause,
    required this.documentRequirements,
  });
}

@immutable
class TenantDocumentRequirement {
  final String id;
  final String label;
  final bool required;
  final String status;
  final String? filename;
  final String? rejectionReason;

  const TenantDocumentRequirement({
    required this.id,
    required this.label,
    required this.required,
    required this.status,
    required this.filename,
    required this.rejectionReason,
  });

  factory TenantDocumentRequirement.fromJson(Map<String, dynamic> json) {
    return TenantDocumentRequirement(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      required: json['required'] as bool? ?? false,
      status: json['status']?.toString() ?? 'required',
      filename: json['filename']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
    );
  }

  TenantDocumentRequirement copyWith({
    String? id,
    String? label,
    bool? required,
    String? status,
    String? filename,
    String? rejectionReason,
  }) {
    return TenantDocumentRequirement(
      id: id ?? this.id,
      label: label ?? this.label,
      required: required ?? this.required,
      status: status ?? this.status,
      filename: filename ?? this.filename,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

/// Simple submission view for UI tracking; backend currently folds this into the requirement.
@immutable
class TenantDocumentSubmission {
  final String requirementId;
  final String? filename;
  final String status;

  const TenantDocumentSubmission({
    required this.requirementId,
    required this.filename,
    required this.status,
  });
}

@immutable
class InviteOnboardingStatus {
  final String code;
  final bool completed;

  const InviteOnboardingStatus({
    required this.code,
    required this.completed,
  });

  factory InviteOnboardingStatus.fromJson(Map<String, dynamic> json) {
    return InviteOnboardingStatus(
      code: json['code']?.toString() ?? '',
      completed: json['completed'] as bool? ?? false,
    );
  }
}

