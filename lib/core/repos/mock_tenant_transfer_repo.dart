import '../../features/tenant_transfer/models/tenant_transfer_models.dart';
import 'tenant_transfer_repo.dart';

class MockTenantTransferRepo implements TenantTransferRepo {
  final List<TransferRequest> _landlordRequests = [];
  TransferRequest? _myActiveRequest;

  MockTenantTransferRepo() {
    _seedData();
  }

  void _seedData() {
    _landlordRequests.addAll([
      TransferRequest(
        id: 'TR-001',
        tenantId: 't-alice',
        tenantName: 'Alice Chen',
        targetEmailOrCode: 'landlord@example.com',
        note: 'Moving to new building. Would like to share my verified rental history.',
        status: TransferRequestStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        decidedAt: null,
        landlordMessage: null,
      ),
      TransferRequest(
        id: 'TR-002',
        tenantId: 't-bob',
        tenantName: 'Bob Williams',
        targetEmailOrCode: 'pm@downtown.com',
        note: 'Transferring units. I have 3 years of on-time payments.',
        status: TransferRequestStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        decidedAt: null,
        landlordMessage: null,
      ),
    ]);
  }

  @override
  Future<TenantProfile> getMyTenantProfile() async {
    await Future.delayed(const Duration(milliseconds: 280));
    return _strongTenantProfile();
  }

  @override
  Future<TransferRequest?> getMyActiveTransferRequest() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _myActiveRequest;
  }

  @override
  Future<TransferRequest> createTransferRequest({
    required String targetEmailOrCode,
    required String note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final profile = _strongTenantProfile();
    final req = TransferRequest(
      id: 'TR-${DateTime.now().millisecondsSinceEpoch}',
      tenantId: profile.tenantId,
      tenantName: profile.fullName,
      targetEmailOrCode: targetEmailOrCode.trim(),
      note: note.trim(),
      status: TransferRequestStatus.pending,
      createdAt: DateTime.now(),
      decidedAt: null,
      landlordMessage: null,
    );
    _myActiveRequest = req;
    _landlordRequests.insert(0, req);
    return req;
  }

  @override
  Future<List<TransferRequest>> listTransferRequestsForLandlord({String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (status == null || status.isEmpty || status == 'all') {
      return List.from(_landlordRequests);
    }
    final statusEnum = status == 'pending'
        ? TransferRequestStatus.pending
        : status == 'accepted'
            ? TransferRequestStatus.accepted
            : status == 'rejected'
                ? TransferRequestStatus.rejected
                : null;
    if (statusEnum == null) return List.from(_landlordRequests);
    return _landlordRequests.where((r) => r.status == statusEnum).toList();
  }

  @override
  Future<TransferRequest> decideTransferRequest({
    required String requestId,
    required bool accept,
    String? landlordMessage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _landlordRequests.indexWhere((r) => r.id == requestId);
    if (idx < 0) {
      throw StateError('Transfer request not found: $requestId');
    }
    final old = _landlordRequests[idx];
    final updated = TransferRequest(
      id: old.id,
      tenantId: old.tenantId,
      tenantName: old.tenantName,
      targetEmailOrCode: old.targetEmailOrCode,
      note: old.note,
      status: accept ? TransferRequestStatus.accepted : TransferRequestStatus.rejected,
      createdAt: old.createdAt,
      decidedAt: DateTime.now(),
      landlordMessage: landlordMessage,
    );
    _landlordRequests[idx] = updated;
    if (_myActiveRequest?.id == requestId) {
      _myActiveRequest = updated;
    }
    return updated;
  }

  TenantProfile _strongTenantProfile() {
    return TenantProfile(
      id: 'tp-demo-1',
      tenantId: 't-demo',
      fullName: 'M. Chen',
      phone: '+1 (555) 123-4567',
      email: 'm.chen@example.com',
      currentAddress: '123 Main St, Apt 3C, Buffalo, NY 14201',
      occupancyHistory: [
        OccupancyRecord(
          propertyName: 'Elm Street Apartments',
          unitLabel: 'Unit 3C',
          startDate: DateTime(2022, 3, 1),
          endDate: null,
          landlordName: 'Elmwood Property Mgmt',
        ),
        OccupancyRecord(
          propertyName: 'Downtown Lofts',
          unitLabel: 'Apt 7B',
          startDate: DateTime(2020, 6, 15),
          endDate: DateTime(2022, 2, 28),
          landlordName: 'City Living LLC',
        ),
      ],
      paymentScore: 92,
      reviews: [
        TenantReview(
          id: 'rev-1',
          reviewerName: 'Elmwood Property Mgmt',
          rating: 5,
          comment: 'Excellent tenant. Always on time with rent and kept the unit in great condition.',
          createdAt: DateTime(2023, 1, 15),
        ),
        TenantReview(
          id: 'rev-2',
          reviewerName: 'City Living LLC',
          rating: 4,
          comment: 'Solid tenant. Occasional late payment but otherwise reliable.',
          createdAt: DateTime(2022, 3, 1),
        ),
      ],
      documents: [
        ProfileDocument(id: 'doc-1', type: 'ID', filename: 'id.pdf', status: 'verified'),
        ProfileDocument(id: 'doc-2', type: 'Paystub', filename: 'paystub.pdf', status: 'uploaded'),
        ProfileDocument(id: 'doc-3', type: 'Lease', filename: 'current_lease.pdf', status: 'verified'),
        ProfileDocument(id: 'doc-4', type: 'Other', filename: 'reference.pdf', status: 'missing'),
      ],
      createdAt: DateTime(2022, 3, 1),
    );
  }
}
