import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/backend/api_base_url.dart';
import 'lease_onboarding_models.dart';

class LeaseOnboardingApi {
  LeaseOnboardingApi(this._tokenGetter);

  final String? Function() _tokenGetter;

  Future<LeasePacket> createPacket({
    required String unitId,
    required String tenantName,
    required String tenantContact,
    required DateTime leaseStartDate,
    required int leaseTermMonths,
    required double monthlyRent,
    required double securityDeposit,
    required String utilitiesResponsibility,
    required bool petsAllowed,
    String? specialNotes,
  }) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri = Uri.parse('$baseUrl/api/v1/lease-onboarding/packets');

    final headers = _buildHeaders();
    final body = <String, dynamic>{
      'unitId': unitId,
      'tenantName': tenantName,
      'tenantContact': tenantContact,
      'leaseStartDate': leaseStartDate.toIso8601String().split('T').first,
      'leaseTermMonths': leaseTermMonths,
      'monthlyRent': monthlyRent,
      'securityDeposit': securityDeposit,
      'utilitiesResponsibility': utilitiesResponsibility,
      'petsAllowed': petsAllowed,
      if (specialNotes != null && specialNotes.trim().isNotEmpty)
        'specialNotes': specialNotes.trim(),
    };

    final res = await http
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    return _parsePacketResponse(res, expectedStatus: 201);
  }

  Future<LeasePacket> getPacket(String packetId) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri = Uri.parse('$baseUrl/api/v1/lease-onboarding/packets/$packetId');
    final res = await http
        .get(uri, headers: _buildHeaders(acceptOnly: true))
        .timeout(const Duration(seconds: 15));
    return _parsePacketResponse(res);
  }

  Future<LeasePacket> getPacketByInviteToken(String inviteUrlToken) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri =
        Uri.parse('$baseUrl/api/v1/lease-onboarding/packets/by-invite/$inviteUrlToken');
    final res = await http
        .get(uri, headers: _buildHeaders(acceptOnly: true))
        .timeout(const Duration(seconds: 15));
    return _parsePacketResponse(res);
  }

  Future<LeasePacket> updatePacket({
    required String packetId,
    DateTime? leaseStartDate,
    int? leaseTermMonths,
    double? monthlyRent,
    double? securityDeposit,
    String? utilitiesResponsibility,
    bool? petsAllowed,
    String? specialNotes,
    DateTime? leaseEndDate,
    int? rentDueDay,
    String? lateFeeClause,
    List<TenantDocumentRequirement>? documentRequirements,
    String? status,
  }) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri = Uri.parse('$baseUrl/api/v1/lease-onboarding/packets/$packetId');

    final body = <String, dynamic>{};
    if (leaseStartDate != null) {
      body['leaseStartDate'] =
          leaseStartDate.toIso8601String().split('T').first;
    }
    if (leaseTermMonths != null) body['leaseTermMonths'] = leaseTermMonths;
    if (monthlyRent != null) body['monthlyRent'] = monthlyRent;
    if (securityDeposit != null) body['securityDeposit'] = securityDeposit;
    if (utilitiesResponsibility != null) {
      body['utilitiesResponsibility'] = utilitiesResponsibility;
    }
    if (petsAllowed != null) body['petsAllowed'] = petsAllowed;
    if (specialNotes != null) body['specialNotes'] = specialNotes;
    if (leaseEndDate != null) {
      body['leaseEndDate'] = leaseEndDate.toIso8601String().split('T').first;
    }
    if (rentDueDay != null) body['rentDueDay'] = rentDueDay;
    if (lateFeeClause != null) body['lateFeeClause'] = lateFeeClause;
    if (documentRequirements != null) {
      body['documentRequirements'] = documentRequirements
          .map((d) => {
                'id': d.id,
                'label': d.label,
                'required': d.required,
              })
          .toList();
    }
    if (status != null) body['status'] = status;

    final res = await http
        .patch(uri, headers: _buildHeaders(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _parsePacketResponse(res);
  }

  Future<LeasePacket> attachInvite({
    required String packetId,
    required String inviteId,
    required String inviteUrlToken,
  }) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri = Uri.parse(
        '$baseUrl/api/v1/lease-onboarding/packets/$packetId/attach-invite');
    final body = {
      'inviteId': inviteId,
      'inviteUrlToken': inviteUrlToken,
    };
    final res = await http
        .post(uri, headers: _buildHeaders(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _parsePacketResponse(res);
  }

  Future<LeasePacket> acknowledgeLease({
    required String packetId,
    required String typedName,
  }) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri = Uri.parse(
        '$baseUrl/api/v1/lease-onboarding/packets/$packetId/tenant/acknowledge');
    final body = {'typedName': typedName};
    final res = await http
        .post(uri, headers: _buildHeaders(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _parsePacketResponse(res);
  }

  Future<LeasePacket> uploadTenantDocument({
    required String packetId,
    required String docId,
    required String filename,
  }) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri = Uri.parse(
        '$baseUrl/api/v1/lease-onboarding/packets/$packetId/tenant/documents/$docId');
    final body = {'filename': filename};
    final res = await http
        .post(uri, headers: _buildHeaders(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _parsePacketResponse(res);
  }

  Future<LeasePacket> submitTenantPacket({
    required String packetId,
  }) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri = Uri.parse(
        '$baseUrl/api/v1/lease-onboarding/packets/$packetId/tenant/submit');
    final res = await http
        .post(uri, headers: _buildHeaders(), body: jsonEncode(<String, dynamic>{}))
        .timeout(const Duration(seconds: 15));
    return _parsePacketResponse(res);
  }

  Future<LeasePacket> reviewPacket({
    required String packetId,
    bool? approved,
    List<LeaseReviewDecision>? documentDecisions,
  }) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri =
        Uri.parse('$baseUrl/api/v1/lease-onboarding/packets/$packetId/review');
    final body = <String, dynamic>{
      if (approved != null) 'approved': approved,
      if (documentDecisions != null)
        'documentDecisions': documentDecisions
            .map((d) => {
                  'id': d.id,
                  'approved': d.approved,
                  if (d.reason != null && d.reason!.trim().isNotEmpty)
                    'reason': d.reason!.trim(),
                })
            .toList(),
    };
    final res = await http
        .post(uri, headers: _buildHeaders(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _parsePacketResponse(res);
  }

  Map<String, String> _buildHeaders({bool acceptOnly = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (!acceptOnly) {
      headers['Content-Type'] = 'application/json';
    }
    final token = _tokenGetter();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  LeasePacket _parsePacketResponse(http.Response res, {int? expectedStatus}) {
    final status = res.statusCode;
    if (expectedStatus != null && status != expectedStatus) {
      throw LeaseOnboardingApiException(
        statusCode: status,
        message: 'Unexpected status $status',
        body: res.body,
      );
    }
    if (status < 200 || status >= 300) {
      String? message;
      try {
        if (res.body.isNotEmpty) {
          final decoded = jsonDecode(res.body);
          if (decoded is Map && decoded['message'] is String) {
            message = decoded['message'] as String;
          }
        }
      } catch (_) {}
      message ??= 'Lease onboarding request failed (status $status).';
      throw LeaseOnboardingApiException(
        statusCode: status,
        message: message,
        body: res.body,
      );
    }
    if (res.body.isEmpty) {
      throw LeaseOnboardingApiException(
        statusCode: status,
        message: 'Empty response from lease onboarding endpoint',
        body: res.body,
      );
    }
    final json = jsonDecode(res.body);
    if (json is! Map) {
      throw LeaseOnboardingApiException(
        statusCode: status,
        message: 'Unexpected lease onboarding response',
        body: res.body,
      );
    }
    return LeasePacket.fromJson(json.cast<String, dynamic>());
  }
}

class LeaseOnboardingApiException implements Exception {
  LeaseOnboardingApiException({
    required this.statusCode,
    required this.message,
    this.body,
  });

  final int statusCode;
  final String message;
  final String? body;

  @override
  String toString() => 'LeaseOnboardingApiException($statusCode): $message';
}

/// Landlord document decision payload used by reviewPacket().
class LeaseReviewDecision {
  LeaseReviewDecision({
    required this.id,
    required this.approved,
    this.reason,
  });

  final String id;
  final bool approved;
  final String? reason;
}


