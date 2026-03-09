import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/backend/api_base_url.dart';

class AuthEmailApiException implements Exception {
  AuthEmailApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

Future<void> verifyEmail(String token) async {
  final baseUrl = await resolveApiBaseUrl();
  final uri = Uri.parse('$baseUrl/v1/auth/verify-email');
  final res = await http
      .post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'token': token}),
      )
      .timeout(const Duration(seconds: 15));
  if (res.statusCode >= 200 && res.statusCode < 300) return;
  final msg = _errorMessage(res);
  throw AuthEmailApiException(msg, statusCode: res.statusCode);
}

Future<void> forgotPassword(String email) async {
  final baseUrl = await resolveApiBaseUrl();
  final uri = Uri.parse('$baseUrl/v1/auth/forgot-password');
  final res = await http
      .post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email}),
      )
      .timeout(const Duration(seconds: 15));
  if (res.statusCode >= 200 && res.statusCode < 300) return;
  final msg = _errorMessage(res);
  throw AuthEmailApiException(msg, statusCode: res.statusCode);
}

Future<void> resetPassword({required String token, required String newPassword}) async {
  final baseUrl = await resolveApiBaseUrl();
  final uri = Uri.parse('$baseUrl/v1/auth/reset-password');
  final res = await http
      .post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'token': token, 'newPassword': newPassword}),
      )
      .timeout(const Duration(seconds: 15));
  if (res.statusCode >= 200 && res.statusCode < 300) return;
  final msg = _errorMessage(res);
  throw AuthEmailApiException(msg, statusCode: res.statusCode);
}

String _errorMessage(http.Response res) {
  try {
    final d = jsonDecode(res.body);
    if (d is Map && d['message'] != null) return d['message'] as String;
  } catch (_) {}
  if (res.statusCode == 429) return 'Too many attempts. Try again later.';
  if (res.statusCode == 401) return 'Invalid or expired link.';
  return 'Something went wrong. Please try again.';
}
