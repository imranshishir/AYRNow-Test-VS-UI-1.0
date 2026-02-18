import '../../models/role.dart';
import '../../models/user.dart';

class MeDto {
  MeDto({
    required this.id,
    required this.name,
    required this.role,
  });

  final String id;
  final String name;
  final String role;

  factory MeDto.fromJson(Map<String, dynamic> json) {
    return MeDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'tenant',
    );
  }
}

AppUser meDtoToModel(MeDto dto) {
  UserRole role = UserRole.tenant;
  switch (dto.role.toLowerCase()) {
    case 'landlord':
      role = UserRole.landlord;
      break;
    case 'tenant':
      role = UserRole.tenant;
      break;
    case 'contractor':
      role = UserRole.contractor;
      break;
    case 'guard':
      role = UserRole.guard;
      break;
    case 'investor':
      role = UserRole.investor;
      break;
    case 'admin':
      role = UserRole.admin;
      break;
  }
  return AppUser(id: dto.id, name: dto.name, role: role);
}
