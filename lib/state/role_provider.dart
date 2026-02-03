import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/models/user_role.dart';

final currentRoleProvider = StateProvider<UserRole>((ref) => UserRole.landlord);
final isLoggedInProvider = StateProvider<bool>((ref) => false);
