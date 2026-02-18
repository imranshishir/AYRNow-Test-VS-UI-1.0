import '../../models/rent.dart';

class RentBoardItemDto {
  RentBoardItemDto({
    required this.tenantName,
    required this.unit,
    required this.amountDue,
    required this.dueDate,
    required this.status,
  });

  final String tenantName;
  final String unit;
  final double amountDue;
  final DateTime dueDate;
  final String status;

  factory RentBoardItemDto.fromJson(Map<String, dynamic> json) {
    final due = json['dueDate'];
    DateTime dueDate = DateTime.now();
    if (due != null) {
      if (due is String) dueDate = DateTime.tryParse(due) ?? dueDate;
      if (due is int) dueDate = DateTime.fromMillisecondsSinceEpoch(due);
    }
    return RentBoardItemDto(
      tenantName: json['tenantName'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      amountDue: (json['amountDue'] as num?)?.toDouble() ?? 0,
      dueDate: dueDate,
      status: json['status'] as String? ?? 'Pending',
    );
  }
}

RentItem rentBoardItemDtoToModel(RentBoardItemDto dto) {
  return RentItem(
    tenantName: dto.tenantName,
    unit: dto.unit,
    amountDue: dto.amountDue,
    dueDate: dto.dueDate,
    status: dto.status,
  );
}
