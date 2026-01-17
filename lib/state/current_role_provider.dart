import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/models/role.dart';

/// Null means "no role selected yet" (show role selection UI).
final currentRoleProvider = StateProvider<UserRole?>((ref) => null);
