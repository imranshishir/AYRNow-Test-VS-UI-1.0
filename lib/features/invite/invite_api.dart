import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/backend/api_base_url.dart';
import 'invite_dto.dart';

class InviteApi {
  InviteApi(this._tokenGetter);

  final String? Function() _tokenGetter;

  Future<InviteDto> createUnitInvite({
    required String unitId,
    required String contactType,
    required String contactValue,
    required String role,
  }) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri = Uri.parse('$baseUrl/v1/units/$unitId/invites');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = _tokenGetter();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final body = <String, dynamic>{
      'contactType': contactType,
      'contactValue': contactValue,
      'role': role,
    };

    final res = await http
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    final status = res.statusCode;
    Map<String, dynamic>? json;
    try {
      if (res.body.isNotEmpty) {
        json = jsonDecode(res.body) as Map<String, dynamic>?;
      }
    } catch (_) {
      // ignore parse errors; handled below
    }

    if (status >= 200 && status < 300) {
      if (json == null) {
        throw InviteApiException(
          statusCode: status,
          message: 'Empty response from invite endpoint',
          body: res.body,
        );
      }
      return InviteDto.fromJson(json);
    }

    final message = (json?['message'] as String?) ??
        'Unable to create invite (status $status).';
    throw InviteApiException(statusCode: status, message: message, body: res.body);
  }

  Future<InviteDto> acceptInvite({required String inviteUrlToken}) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri = Uri.parse('$baseUrl/v1/invites/accept/$inviteUrlToken');

    final headers = <String, String>{
      'Accept': 'application/json',
    };
    final token = _tokenGetter();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final res =
        await http.post(uri, headers: headers).timeout(const Duration(seconds: 15));

    final status = res.statusCode;
    Map<String, dynamic>? json;
    try {
      if (res.body.isNotEmpty) {
        json = jsonDecode(res.body) as Map<String, dynamic>?;
      }
    } catch (_) {}

    if (status >= 200 && status < 300) {
      if (json == null) {
        throw InviteApiException(
          statusCode: status,
          message: 'Empty response from invite accept endpoint',
          body: res.body,
        );
      }
      return InviteDto.fromJson(json);
    }

    final message = (json?['message'] as String?) ??
        'Unable to accept invite (status $status).';
    throw InviteApiException(statusCode: status, message: message, body: res.body);
  }
}

class InviteApiException implements Exception {
  InviteApiException({
    required this.statusCode,
    required this.message,
    this.body,
  });

  final int statusCode;
  final String message;
  final String? body;

  @override
  String toString() => 'InviteApiException($statusCode): $message';
}

