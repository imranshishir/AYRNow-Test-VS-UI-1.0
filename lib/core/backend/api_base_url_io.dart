import 'dart:io' show Platform;

import 'api_config.dart';

/// Platform-specific default when running on iOS/Android (dart:io available).
String getPlatformDefaultBaseUrl() {
  const port = '8081';
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:$port'; // Android emulator host loopback
  }
  if (Platform.isIOS) {
    return 'http://127.0.0.1:$port'; // iOS Simulator
  }
  return defaultBaseUrl;
}
