import 'package:flutter/material.dart';
import '../ui/spec_screen.dart';
import '../ui/spec_index_screen.dart';
import '../features/landlord/l12_dashboard.dart';
import '../features/landlord/l23_rent_board.dart';
import '../features/landlord/l30_maintenance_inbox.dart';
import '../features/tenant/t06_dashboard.dart';
import '../features/tenant/t10_pay_rent.dart';
import '../features/contractor/c10_jobs_feed.dart';
import '../features/guard/s10_approvals_queue.dart';
import '../features/community/screens/community_home_screen.dart';
import '../features/community/screens/community_create_post_screen.dart';
import '../features/tenant_transfer/screens/tenant_profile_export_screen.dart';
import '../features/tenant_transfer/screens/tenant_transfer_request_screen.dart';
import '../features/tenant_transfer/screens/landlord_transfer_inbox_screen.dart';
import '../features/household/screens/tenant_household_screen.dart';
import '../features/household/screens/invite_household_member_screen.dart';
import '../features/household/screens/landlord_unit_residents_screen.dart';
import '../features/landlord/screens/unit_detail_screen.dart';

Map<String, WidgetBuilder> buildRoutes() {
  final routes = <String, WidgetBuilder>{};


  // Real screens
  routes['/L-12'] = (_) => const LandlordDashboardScreen();
  routes['/L-23'] = (_) => const RentBoardScreen();
  routes['/L-30'] = (_) => const MaintenanceInboxScreen();
  routes['/L-24'] = (_) => const UnitDetailScreen();
  routes['/T-06'] = (_) => const TenantDashboardScreen();
  routes['/T-10'] = (_) => const PayRentScreen();
  routes['/T-45'] = (_) => const TenantProfileExportScreen();
  routes['/T-45/request'] = (_) => const TenantTransferRequestScreen();
  routes['/L-45'] = (_) => const LandlordTransferInboxScreen();
  routes['/T-50'] = (_) => const TenantHouseholdScreen();
  routes['/T-50/invite'] = (_) => const InviteHouseholdMemberScreen();
  routes['/L-50'] = (_) => const LandlordUnitResidentsScreen();
  routes['/C-10'] = (_) => const ContractorJobsFeedScreen();
  routes['/S-10'] = (_) => const GuardApprovalsQueueScreen();

  routes['/community'] = (_) => const CommunityHomeScreen(isLandlord: false);
  routes['/L-40'] = (_) => const CommunityHomeScreen(isLandlord: true);
  routes['/T-40'] = (_) => const CommunityHomeScreen(isLandlord: false);
  routes['/community/new'] = (_) => CommunityCreatePostScreen(
        isLandlord: true,
        authorName: 'Demo Landlord',
        authorRole: 'landlord',
        onCreated: () {},
      );

  const ids = <String>[
    'L-01',
    'L-02',
    'L-03',
    'L-04',
    'L-05',
    'L-06',
    'L-07',
    'L-07U',
    'L-08',
    'L-09',
    'L-10',
    'L-11',
    'L-11E',
    'L-12',
    'L-20',
    'L-21',
    'L-22',
    'L-23',
    'L-23F',
    'L-24',
    'L-25',
    'L-26',
    'L-27',
    'L-28',
    'L-30',
    'L-45',
    'L-50',
    'L-31',
    'L-31R',
    'L-32',
    'L-33',
    'L-34',
    'L-35',
    'L-35U',
    'L-36',
    'L-37',
    'L-38',
    'T-01',
    'T-02',
    'T-03',
    'T-04',
    'T-05',
    'T-06',
    'T-45',
    'T-07',
    'T-07E',
    'T-10',
    'T-50',
    'T-11',
    'T-12',
    'T-13',
    'T-14',
    'T-14D',
    'T-20',
    'T-21',
    'T-22',
    'T-23',
    'C-01',
    'C-02',
    'C-03',
    'C-04P',
    'C-04',
    'C-10',
    'C-20',
    'C-21',
    'C-22',
    'C-30',
    'C-31',
    'C-32',
    'C-40',
    'C-41',
    'S-01',
    'S-02',
    'S-10',
    'S-11',
    'S-20',
    'S-21',
    'S-30',
    'I-01',
    'I-02',
    'I-10',
    'I-11',
    'I-12',
    'I-20',
    'I-30',
    'A-01',
    'A-02',
    'A-10',
    'A-11',
    'A-12',
    'A-20',
    'A-21',
    'A-22',
    'A-40',
    'A-41',
    'A-50',
    'A-50F',
  ];

  // Spec index
  routes['/spec'] = (_) => SpecIndexScreen(ids: ids);


  for (final id in ids) {
    routes.putIfAbsent('/$id', () => (_) => SpecScreen(
      id: id,
      title: 'Screen $id',
      purpose: 'Placeholder. Replace with real UI per wireframe specs PDF.',
      components: const ['See wireframe-ready screen specs document for components/states.'],
      actions: const ['Implement actions + validation as defined in specs.'],
      states: const ['Loading', 'Empty', 'Error', 'Success'],
    ));
  }
  return routes;
}
