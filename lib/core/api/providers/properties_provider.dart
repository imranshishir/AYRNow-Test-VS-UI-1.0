import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/api/endpoints/properties_api.dart';
import 'package:ayrnow/core/api/providers/api_client_provider.dart';
import 'package:ayrnow/core/api/providers/feature_flags_provider.dart';

/// List provider. After create/update/delete: ref.invalidate(propertiesListProvider).
final propertiesListProvider =
    FutureProvider.autoDispose<List<PropertyResponse>>((ref) async {
  final useRealApi = ref.watch(featureFlagsProvider).properties;
  if (!useRealApi) {
    return [];
  }
  final dio = ref.watch(apiClientProvider);
  final api = PropertiesApi(dio);
  return api.list();
});
