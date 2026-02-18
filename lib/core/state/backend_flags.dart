import 'package:flutter_riverpod/flutter_riverpod.dart';

/// When true, use ApiRepos for me, rent board, tickets, notifications.
/// Default false = MockRepos everywhere.
final useApiBackendProvider = StateProvider<bool>((_) => false);
