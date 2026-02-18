import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/backend/providers/backend_providers.dart';

/// Starts AppSessionService for session sync (auth state, tenantContext).
/// Always runs; lease query is gated by useFirebaseBackendProvider inside service.
class FirebaseSessionBootstrap extends ConsumerStatefulWidget {
  const FirebaseSessionBootstrap({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<FirebaseSessionBootstrap> createState() =>
      _FirebaseSessionBootstrapState();
}

class _FirebaseSessionBootstrapState extends ConsumerState<FirebaseSessionBootstrap> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStart());
  }

  void _maybeStart() {
    if (!mounted) return;
    final useFirebase = ref.read(useFirebaseBackendProvider);
    if (!useFirebase) return;
    try {
      ref.read(appSessionServiceProvider).start();
      _started = true;
    } catch (_) {
      // Firebase not configured; ignore
    }
  }

  @override
  void dispose() {
    if (_started) {
      try {
        ref.read(appSessionServiceProvider).dispose();
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
