import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_base_url_stub.dart' if (dart.library.io) 'api_base_url_io.dart' as platform;
import 'api_config.dart';

const String _keyApiBaseUrlOverride = 'apiBaseUrlOverride';

/// Resolves the API base URL: stored dev override, else in release mode production URL, else platform default (e.g. 10.0.2.2 for Android emulator).
Future<String> resolveApiBaseUrl() async {
  final prefs = await SharedPreferences.getInstance();
  final override = prefs.getString(_keyApiBaseUrlOverride);
  if (override != null && override.trim().isNotEmpty) {
    final url = override.trim();
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
  if (kReleaseMode) {
    return productionApiBaseUrl;
  }
  return platform.getPlatformDefaultBaseUrl();
}

/// Saves a dev-only override. Pass null or empty to clear (reset to default).
Future<void> saveApiBaseUrlOverride(String? url) async {
  final prefs = await SharedPreferences.getInstance();
  if (url == null || url.trim().isEmpty) {
    await prefs.remove(_keyApiBaseUrlOverride);
  } else {
    final trimmed = url.trim();
    await prefs.setString(_keyApiBaseUrlOverride, trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed);
  }
}

/// Returns the current override if set, else null.
Future<String?> getApiBaseUrlOverride() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyApiBaseUrlOverride);
}
