// Backend-ready request/response contracts for tenant transfer.
// No networking - types only for future REST alignment.

class CreateTransferRequestRequest {
  final String targetEmailOrCode;
  final String? note;

  const CreateTransferRequestRequest({
    required this.targetEmailOrCode,
    this.note,
  });
}

class TransferDecisionRequest {
  final bool accept;
  final String? landlordMessage;

  const TransferDecisionRequest({
    required this.accept,
    this.landlordMessage,
  });
}

class TransferRequestResponse {
  final String requestId;
  final String status;

  const TransferRequestResponse({
    required this.requestId,
    required this.status,
  });
}
