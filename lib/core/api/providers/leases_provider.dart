import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/api/endpoints/leases_api.dart';
import 'package:ayrnow/core/api/providers/api_client_provider.dart';
import 'package:ayrnow/core/api/providers/feature_flags_provider.dart';

/// Active lease for current tenant. Null if none or not tenant.
final activeLeaseProvider =
    FutureProvider.autoDispose<LeaseResponse?>((ref) async {
  if (!ref.watch(featureFlagsProvider).leases) return null;
  final dio = ref.watch(apiClientProvider);
  final api = LeasesApi(dio);
  return api.getActiveOrNull();
});
