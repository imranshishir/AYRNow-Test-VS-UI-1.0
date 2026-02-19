// API backend configuration. Override via api_base_url.dart (dev override or platform default).

const String defaultBaseUrl = 'http://localhost:8080';

/// Base URL for API requests. Prefer resolveApiBaseUrl() for runtime (dev override + platform).
String get apiBaseUrl => defaultBaseUrl;
