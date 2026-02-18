import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Thin wrapper over HTTP client for API calls.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    this.tokenGetter,
    this.timeout = const Duration(seconds: 15),
  });

  final String baseUrl;
  final Future<String?> Function()? tokenGetter;
  final Duration timeout;

  String _url(String path, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParams == null || queryParams.isEmpty) return uri.toString();
    return uri.replace(queryParameters: queryParams).toString();
  }

  /// Returns decoded JSON (Map or List). Use for flexible response shapes.
  Future<dynamic> getJsonRaw(String path, [Map<String, String>? queryParams]) async {
    final headers = await _headers();
    try {
      final response = await http
          .get(Uri.parse(_url(path, queryParams)), headers: headers)
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      }
      _throwFromResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(null, 'Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getJson(String path, [Map<String, String>? queryParams]) async {
    final raw = await getJsonRaw(path, queryParams);
    if (raw is Map<String, dynamic>) return raw;
    return {};
  }

  Never _throwFromResponse(http.Response response) {
    String message = 'Request failed';
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>?;
      message = (json?['message'] ?? json?['error'])?.toString() ?? message;
    } catch (_) {}
    throw ApiException(response.statusCode, message);
  }

  Future<Map<String, dynamic>> postJson(String path, [Object? body]) async {
    final headers = await _headers();
    try {
      final response = await http
          .post(
            Uri.parse(_url(path)),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(null, 'Network error: $e');
    }
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty || response.statusCode == 204) return {};
      try {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> ? decoded : {};
      } catch (_) {
        return {};
      }
    }
    _throwFromResponse(response);
  }

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (tokenGetter != null) {
      final token = await tokenGetter!();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }
}
