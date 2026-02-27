class PaymentIntentDto {
  PaymentIntentDto({
    required this.paymentId,
    required this.status,
    this.clientSecret,
  });

  final String paymentId;
  final String status;
  final String? clientSecret;

  factory PaymentIntentDto.fromJson(Map<String, dynamic> json) {
    return PaymentIntentDto(
      paymentId: json['paymentId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      clientSecret: json['clientSecret'] as String?,
    );
  }
}

