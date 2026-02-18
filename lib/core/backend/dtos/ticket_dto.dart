import '../../models/ticket.dart';

class TicketDto {
  TicketDto({
    required this.id,
    required this.unit,
    required this.title,
    required this.priority,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String unit;
  final String title;
  final String priority;
  final DateTime createdAt;
  final String status;

  factory TicketDto.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    DateTime created = DateTime.now();
    if (createdAt != null) {
      if (createdAt is String) created = DateTime.tryParse(createdAt) ?? created;
      if (createdAt is int) created = DateTime.fromMillisecondsSinceEpoch(createdAt);
    }
    return TicketDto(
      id: json['id'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      title: json['title'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Med',
      createdAt: created,
      status: json['status'] as String? ?? 'Open',
    );
  }
}

MaintenanceTicket ticketDtoToModel(TicketDto dto) {
  return MaintenanceTicket(
    id: dto.id,
    unit: dto.unit,
    title: dto.title,
    priority: dto.priority,
    createdAt: dto.createdAt,
    status: dto.status,
  );
}
