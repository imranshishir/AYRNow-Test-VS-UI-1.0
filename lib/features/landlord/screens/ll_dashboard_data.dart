import 'package:ayrnow/features/landlord/screens/landlord_demo_store.dart';

class LlDashboardData {
  final int properties;
  final int units;
  final double outstanding;
  final int openTickets;
  final int overduePayments;
  final int urgentTickets;

  const LlDashboardData({
    required this.properties,
    required this.units,
    required this.outstanding,
    required this.openTickets,
    required this.overduePayments,
    required this.urgentTickets,
  });

  double get totalCollectedThisMonth => 12450.0;
  double get collectionRatePercent => outstanding > 0 ? 87.5 : 100.0;
  double get occupancyRatePercent => units > 0 ? ((units - 1) / units * 100).clamp(0.0, 100.0) : 0.0;
  bool get trendUp => true;
  bool get hasUrgentAttention => outstanding > 0 || openTickets > 0;

  static LlDashboardData fromStore(LandlordDemoStore store) {
    final propertyNames = <String>{};
    final unitKeys = <String>{};

    for (final r in store.rent) {
      propertyNames.add(r.propertyName);
      unitKeys.add('${r.propertyName}::${r.unitLabel}');
    }
    for (final x in store.tickets) {
      propertyNames.add(x.propertyName);
      unitKeys.add('${x.propertyName}::${x.unitLabel}');
    }

    final outstanding = store.rent
        .where((r) => r.status != 'Paid')
        .fold<double>(0, (sum, r) => sum + r.amount);

    final openTickets = store.tickets.where((x) => x.status != 'Completed').length;
    final overduePayments = store.rent.where((r) => r.status == 'Late' || r.status == 'Due').length;
    final urgentTickets = store.tickets.where((x) => x.priority == 'High' && x.status != 'Completed').length;

    return LlDashboardData(
      properties: propertyNames.length,
      units: unitKeys.length,
      outstanding: outstanding,
      openTickets: openTickets,
      overduePayments: overduePayments,
      urgentTickets: urgentTickets,
    );
  }
}
