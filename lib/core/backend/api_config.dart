// API backend configuration. Override via api_base_url.dart (dev override or platform default).
// In release builds, production base URL is used when no override is set.

const String defaultBaseUrl = 'http://localhost:8081';

/// Production API base URL (HTTPS). Used in release builds when no dev override is stored.
const String productionApiBaseUrl = 'https://api.ayrnow.com';

/// Base URL for API requests. Prefer resolveApiBaseUrl() for runtime (dev override + platform or production).
String get apiBaseUrl => defaultBaseUrl;
