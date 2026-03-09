import 'package:flutter/material.dart';
import '../ui/spec_screen.dart';
import '../ui/spec_index_screen.dart';
// Landlord
import '../features/landlord/l12_dashboard.dart';
import '../features/landlord/l20_add_property.dart';
import '../features/landlord/l21_add_unit.dart';
import '../features/landlord/l22_property_detail.dart';
import '../features/landlord/l23_rent_board.dart';
import '../features/landlord/l25_property_list.dart';
import '../features/landlord/l30_maintenance_inbox.dart';
import '../features/landlord/l31_ticket_detail.dart';
import '../features/landlord/l33_create_ticket.dart';
import '../features/landlord/l35_assign_contractor.dart';
import '../features/landlord/l38_settings.dart';
import '../features/landlord/screens/unit_detail_screen.dart';
// Tenant
import '../features/tenant/t06_dashboard.dart';
import '../features/tenant/t07_lease_view.dart';
import '../features/tenant/t10_pay_rent.dart';
import '../features/tenant/t11_payment_method.dart';
import '../features/tenant/t12_payment_confirmation.dart';
import '../features/tenant/t13_receipt_detail.dart';
import '../features/tenant/t14_receipts.dart';
import '../features/tenant/t20_create_ticket.dart';
import '../features/tenant/t21_ticket_list.dart';
import '../features/tenant/t22_ticket_detail.dart';
import '../features/tenant/t23_tenant_settings.dart';
// Contractor
import '../features/contractor/c04_contractor_profile.dart';
import '../features/contractor/c10_jobs_feed.dart';
import '../features/contractor/c20_job_detail.dart';
import '../features/contractor/c21_submit_bid.dart';
import '../features/contractor/c30_earnings.dart';
// Guard
import '../features/guard/s10_approvals_queue.dart';
import '../features/guard/s11_approval_detail.dart';
import '../features/guard/s20_entry_log.dart';
import '../features/guard/s30_guard_settings.dart';
// Investor
import '../features/investor/i12_portfolio_summary.dart';
// Auth
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/verify_email_screen.dart';
import '../features/auth/reset_password_screen.dart';
// Common
import '../features/common/profile_screen.dart';
import '../features/common/notifications_screen.dart';
import '../features/common/settings_screen.dart';
import '../features/common/help_screen.dart';
// Community
import '../features/community/screens/community_home_screen.dart';
import '../features/community/screens/community_create_post_screen.dart';
// Tenant Transfer
import '../features/tenant_transfer/screens/tenant_profile_export_screen.dart';
import '../features/tenant_transfer/screens/tenant_transfer_request_screen.dart';
import '../features/tenant_transfer/screens/landlord_transfer_inbox_screen.dart';
// Household
import '../features/household/screens/tenant_household_screen.dart';
import '../features/household/screens/invite_household_member_screen.dart';
import '../features/household/screens/landlord_unit_residents_screen.dart';
import '../features/invite_accept/invite_accept_screen.dart';

Map<String, WidgetBuilder> buildRoutes() {
  final routes = <String, WidgetBuilder>{};


  // --- Auth --- (do not set /login here; main.dart owns core /login with ui/login_screen)
  routes['/register'] = (_) => const RegisterScreen();
  routes['/forgot-password'] = (_) => const ForgotPasswordScreen();
  routes['/verify-email'] = (_) => const VerifyEmailScreen();
  routes['/reset-password'] = (_) => const ResetPasswordScreen();
  routes['/L-01'] = (_) => const LoginScreen();
  routes['/L-02'] = (_) => const RegisterScreen();
  routes['/T-01'] = (_) => const LoginScreen();
  routes['/T-02'] = (_) => const RegisterScreen();
  routes['/C-01'] = (_) => const LoginScreen();
  routes['/C-02'] = (_) => const RegisterScreen();
  routes['/S-01'] = (_) => const LoginScreen();
  routes['/S-02'] = (_) => const RegisterScreen();
  routes['/I-01'] = (_) => const LoginScreen();
  routes['/I-02'] = (_) => const RegisterScreen();
  routes['/A-01'] = (_) => const LoginScreen();
  routes['/A-02'] = (_) => const RegisterScreen();

  // --- Common ---
  routes['/profile'] = (_) => const ProfileScreen();
  routes['/I-10'] = (_) => const NotificationsScreen();
  routes['/A-20'] = (_) => const GeneralSettingsScreen();
  routes['/help'] = (_) => const HelpScreen();

  // --- Landlord ---
  routes['/L-12'] = (_) => const LandlordDashboardScreen();
  routes['/L-20'] = (_) => const AddPropertyScreen();
  routes['/L-21'] = (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = args is Map ? args : const <String, dynamic>{};
    final propertyId = map['propertyId']?.toString() ?? '';
    final propertyLabel = map['propertyLabel']?.toString();
    return AddUnitScreen(
      propertyId: propertyId,
      propertyLabel: propertyLabel,
    );
  };
  routes['/L-22'] = (_) => const PropertyDetailScreen();
  routes['/L-23'] = (_) => const RentBoardScreen();
  routes['/L-24'] = (_) => const UnitDetailScreen();
  routes['/L-25'] = (_) => const PropertyListScreen();
  routes['/L-30'] = (_) => const MaintenanceInboxScreen();
  routes['/L-31'] = (_) => const TicketDetailScreen();
  routes['/L-33'] = (_) => const LandlordCreateTicketScreen();
  routes['/L-35'] = (_) => const AssignContractorScreen();
  routes['/L-38'] = (_) => const LandlordSettingsScreen();
  routes['/L-45'] = (_) => const LandlordTransferInboxScreen();

  // --- Tenant ---
  routes['/T-06'] = (_) => const TenantDashboardScreen();
  routes['/T-07'] = (_) => const LeaseViewScreen();
  routes['/T-10'] = (_) => const PayRentScreen();
  routes['/T-11'] = (_) => const PaymentMethodScreen();
  routes['/T-12'] = (_) => const PaymentConfirmationScreen();
  routes['/T-13'] = (_) => const ReceiptDetailScreen();
  routes['/T-14'] = (_) => const ReceiptsScreen();
  routes['/T-20'] = (_) => const CreateTicketScreen();
  routes['/T-21'] = (_) => const TenantTicketListScreen();
  routes['/T-22'] = (_) => const TenantTicketDetailScreen();
  routes['/T-23'] = (_) => const TenantSettingsScreen();
  routes['/T-45'] = (_) => const TenantProfileExportScreen();
  routes['/T-45/request'] = (_) => const TenantTransferRequestScreen();
  routes['/T-50'] = (_) => const TenantHouseholdScreen();

  routes['/T-50/invite'] = (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = args is Map ? args : const <String, dynamic>{};
    final unitId = map['unitId']?.toString() ?? '';
    final isLandlord = map['isLandlord'] as bool? ?? false;
    return InviteHouseholdMemberScreen(
      unitId: unitId,
      isLandlord: isLandlord,
    );
  };

  routes['/L-50'] = (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = args is Map ? args : const <String, dynamic>{};
    final unitId = map['unitId']?.toString() ?? '';
    final unitLabel = map['unitLabel']?.toString();
    return LandlordUnitResidentsScreen(
      unitId: unitId,
      unitLabel: unitLabel,
    );
  };

  // --- Contractor ---
  routes['/C-04'] = (_) => const ContractorProfileScreen();
  routes['/C-10'] = (_) => const ContractorJobsFeedScreen();
  routes['/C-20'] = (_) => const JobDetailScreen();
  routes['/C-21'] = (_) => const SubmitBidScreen();
  routes['/C-30'] = (_) => const EarningsDashboardScreen();

  // --- Guard ---
  routes['/S-10'] = (_) => const GuardApprovalsQueueScreen();
  routes['/S-11'] = (_) => const ApprovalDetailScreen();
  routes['/S-20'] = (_) => const EntryLogScreen();
  routes['/S-30'] = (_) => const GuardSettingsScreen();

  // --- Investor ---
  routes['/I-12'] = (_) => const PortfolioSummaryScreen();

  // --- Community ---
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
  routes['/spec'] = (_) => const SpecIndexScreen(ids: ids);

  // Invite deep link landing (expects args: { token: '...' }).
  routes['/invite'] = (_) => const InviteAcceptScreen();


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
