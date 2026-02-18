import '../../features/tenant_transfer/models/tenant_transfer_models.dart';

/// Repository for tenant portable profile and transfer requests.
abstract class TenantTransferRepo {
  Future<TenantProfile> getMyTenantProfile();
  Future<TransferRequest?> getMyActiveTransferRequest();
  Future<TransferRequest> createTransferRequest({
    required String targetEmailOrCode,
    required String note,
  });
  Future<List<TransferRequest>> listTransferRequestsForLandlord({String? status});
  Future<TransferRequest> decideTransferRequest({
    required String requestId,
    required bool accept,
    String? landlordMessage,
  });
}
