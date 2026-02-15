import 'package:ayrnow/features/tenant/screens/t_models.dart';

class MockService {
  MockService._();

  static Future<String> submitRentPayment({
    required TenantProperty property,
    required TenantUnit unit,
    required String method,
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return 'AYR-${DateTime.now().millisecondsSinceEpoch}';
  }

  static Future<TenantTicket> submitMaintenanceRequest({
    required String category,
    required String title,
    required String description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return TenantTicket(
      id: 'T-${DateTime.now().millisecondsSinceEpoch}',
      title: title.isEmpty ? 'Maintenance request' : title,
      category: category,
      status: 'Pending',
      createdLabel: 'Today',
      description: description,
    );
  }

  static Future<bool> validateInviteCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final trimmed = code.trim().toUpperCase();
    if (trimmed.length < 6) return false;
    return RegExp(r'^[A-Z0-9\-]+$').hasMatch(trimmed);
  }

  static bool isValidInviteCodeFormat(String code) {
    final trimmed = code.trim();
    if (trimmed.length < 6) return false;
    return RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(trimmed);
  }
}
