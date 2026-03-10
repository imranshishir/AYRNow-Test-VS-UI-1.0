import 'dart:convert';

import 'package:http/http.dart' as http;

import '../backend/api_base_url.dart';

/// Minimal HTTP API client used by Stripe payments and future real repos.
class ApiClient {
  ApiClient(this._tokenGetter);

  final String? Function() _tokenGetter;

  Future<dynamic> getJson(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParameters,
    );

    final headers = <String, String>{'Accept': 'application/json'};
    final token = _tokenGetter();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response =
        await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
    return _decodeJson(response);
  }

  Future<dynamic> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final baseUrl = await resolveApiBaseUrl();
    final uri = Uri.parse('$baseUrl$path');

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final token = _tokenGetter();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http
        .post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    return _decodeJson(response);
  }

  dynamic _decodeJson(http.Response res) {
    if (res.body.isEmpty) return null;
    try {
      return jsonDecode(res.body);
    } catch (_) {
      return res.body;
    }
  }
}

