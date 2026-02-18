// API backend configuration. Override baseUrl for dev/staging via const or env flavor.

const String defaultBaseUrl = 'http://localhost:8080';

/// Base URL for API requests. Can be overridden per flavor or build.
String get apiBaseUrl => defaultBaseUrl;
