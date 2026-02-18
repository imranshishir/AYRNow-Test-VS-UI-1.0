/// Base URL and environment selection for API client.
/// Override via --dart-define=API_BASE_URL=... or set default below.
class ApiConfig {
  ApiConfig._();

  /// Prefer 127.0.0.1 for iOS simulator; use 10.0.2.2 for Android emulator.
  static const String _defaultBaseUrl = 'http://127.0.0.1:8080';

  /// Base URL (no trailing slash). For iOS simulator use localhost or 127.0.0.1.
  /// For physical device, use machine LAN IP (e.g. http://192.168.1.100:8080).
  static String get baseUrl {
    const fromEnv = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: _defaultBaseUrl,
    );
    return fromEnv;
  }

  static bool get isLocal => baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1');
}
