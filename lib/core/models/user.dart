import 'role.dart';

class AppUser {
  final String id;
  final String name;
  final UserRole role;

  const AppUser({required this.id, required this.name, required this.role});
}
