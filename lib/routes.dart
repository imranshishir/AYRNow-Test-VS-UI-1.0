import 'package:flutter/material.dart';
import 'package:ayrnow/ui/home/home_shell.dart';
import 'package:ayrnow/features/landlord/screens/ll_add_property_screen.dart';
import 'package:ayrnow/features/landlord/screens/ll_properties_list_screen.dart';
import 'package:ayrnow/features/landlord/screens/landlord_demo_store.dart';
import 'package:ayrnow/features/landlord/screens/landlord_rent_screen.dart';
import 'package:ayrnow/features/landlord/screens/landlord_maint_pros_shell_screen.dart';
import 'package:ayrnow/features/landlord/screens/landlord_contractors_screen.dart';
import 'package:ayrnow/features/landlord/screens/landlord_add_property.dart';
import 'package:ayrnow/features/landlord/screens/landlord_property_detail.dart';
import 'package:ayrnow/features/landlord/screens/landlord_unit_detail.dart';
import 'package:ayrnow/features/landlord/screens/landlord_tenant_detail.dart';
import 'package:ayrnow/features/landlord/models/property_models.dart';
import 'package:ayrnow/features/landlord/unit/mock_unit_data.dart';
import 'package:ayrnow/features/invite/screens/invite_tenant_screen.dart';
import 'package:ayrnow/features/invite/screens/pending_invites_screen.dart';
import 'package:ayrnow/features/invite/screens/invite_landing_screen.dart';
import 'package:ayrnow/features/invite/screens/invite_accept_screen.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '';

    if (name.startsWith('/invite/')) {
      final parts = Uri.parse(name).pathSegments;
      if (parts.length == 2) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => InviteLandingScreen(code: parts[1]),
        );
      }
      if (parts.length == 3 && parts[2] == 'accept') {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => InviteAcceptScreen(code: parts[1]),
        );
      }
    }

    switch (name) {
      case '/landlord/add-property':
        return MaterialPageRoute(builder: (_) => const LlAddPropertyScreen());
      case '/landlord/properties':
        return MaterialPageRoute(builder: (_) => const LlPropertiesListScreen());
      case '/landlord/rent':
        return MaterialPageRoute(
          builder: (_) => LandlordRentScreen(store: LandlordDemoStore()),
        );
      case '/landlord/maintenance':
        return MaterialPageRoute(
          builder: (_) => LandlordMaintProsShellScreen(store: LandlordDemoStore()),
        );
      case '/landlord/contractors':
        return MaterialPageRoute(
          builder: (_) => LandlordContractorsScreen(store: LandlordDemoStore()),
        );
      case '/landlord/properties/add':
        return MaterialPageRoute(builder: (_) => const LandlordAddPropertyScreen());
      case '/landlord/properties/detail':
        final property = settings.arguments as PropertyModel;
        return MaterialPageRoute(
          builder: (_) => LandlordPropertyDetailScreen(property: property),
        );
      case '/landlord/unit/detail':
        final args = settings.arguments as Map<String, dynamic>;
        final property = args['property'] as PropertyModel;
        final unit = args['unit'] as UnitModel;
        return MaterialPageRoute(
          builder: (_) => LandlordUnitDetailScreen(property: property, unit: unit),
        );
      case '/landlord/tenant/detail':
        final tenant = settings.arguments as TenantModel;
        return MaterialPageRoute(
          builder: (_) => LandlordTenantDetailScreen(tenant: tenant),
        );
      case '/landlord/unit/invite':
        final bundle = settings.arguments as UnitBundle;
        return MaterialPageRoute(
          builder: (_) => InviteTenantScreen(bundle: bundle),
        );
      case '/landlord/invites':
        return MaterialPageRoute(builder: (_) => const PendingInvitesScreen());
      case '/landlord/invites/property':
        final args = (settings.arguments as Map?) ?? const {};
        return MaterialPageRoute(
          builder: (_) => PendingInvitesScreen(
            propertyId: args['propertyId'] as String?,
            propertyName: args['propertyName'] as String?,
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const HomeShell());
    }
  }
}
