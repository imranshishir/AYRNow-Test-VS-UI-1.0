/// Central Firestore path helpers.
class FirestorePaths {
  FirestorePaths._();

  static String user(String uid) => 'users/$uid';
  static String account(String accountId) => 'accounts/$accountId';
  static String membership(String accountId, String membershipId) =>
      'accounts/$accountId/memberships/$membershipId';

  // Milestone 2: Properties, Units, Leases (collections)
  static String properties(String accountId) =>
      'accounts/$accountId/properties';
  static String units(String accountId, String propertyId) =>
      'accounts/$accountId/properties/$propertyId/units';
  static String leases(String accountId) => 'accounts/$accountId/leases';
}
