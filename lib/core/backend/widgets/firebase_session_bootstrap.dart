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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStart());
  }

  void _maybeStart() {
    ref.read(appSessionServiceProvider).start();
  }

  @override
  void dispose() {
    ref.read(appSessionServiceProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
