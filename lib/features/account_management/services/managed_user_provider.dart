import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/features/account_management/services/mock_managed_user_service.dart';

final managedUserServiceProvider =
    ChangeNotifierProvider<MockManagedUserService>((ref) {
  return MockManagedUserService();
});
