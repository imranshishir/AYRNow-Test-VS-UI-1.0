class TenantPaymentResult {
  final String rentId;
  final double amount;
  final String method;
  final DateTime paidAt;

  const TenantPaymentResult({
    required this.rentId,
    required this.amount,
    required this.method,
    required this.paidAt,
  });
}
