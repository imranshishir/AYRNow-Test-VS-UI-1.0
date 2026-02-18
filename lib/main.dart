import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ayrnow/app.dart';
import 'package:ayrnow/core/api/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    debugPrint('AYRNOW API baseUrl: ${ApiConfig.baseUrl}');
  }
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase not configured (e.g. missing GoogleService-Info.plist).
    // useFirebaseBackendProvider will return false and mock auth will be used.
  }
  runApp(const ProviderScope(child: AyrNowApp()));
}
