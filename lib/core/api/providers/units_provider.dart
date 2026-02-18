import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/api/endpoints/units_api.dart';
import 'package:ayrnow/core/api/providers/api_client_provider.dart';
import 'package:ayrnow/core/api/providers/feature_flags_provider.dart';

final unitsListProvider = FutureProvider.autoDispose
    .family<List<UnitResponse>, String>((ref, propertyId) async {
  final useRealApi = ref.watch(featureFlagsProvider).units;
  if (!useRealApi) return [];
  final dio = ref.watch(apiClientProvider);
  final api = UnitsApi(dio);
  return api.listByProperty(propertyId);
});
