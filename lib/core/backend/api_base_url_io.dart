import 'dart:io' show Platform;

import 'api_config.dart';

/// Platform-specific default when running on iOS/Android (dart:io available).
String getPlatformDefaultBaseUrl() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8080'; // Android emulator host loopback
  }
  if (Platform.isIOS) {
    return 'http://127.0.0.1:8080'; // iOS Simulator; if not reachable, use Settings override to set Mac LAN IP
  }
  return defaultBaseUrl;
}
