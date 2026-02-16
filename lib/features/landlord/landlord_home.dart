import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/landlord_flow.dart';

class LandlordHome extends StatelessWidget {
  const LandlordHome({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the main landlord entry. The drill-down flow starts from dashboard → Properties.
    return const LandlordDashboardScreen();
  }
}
