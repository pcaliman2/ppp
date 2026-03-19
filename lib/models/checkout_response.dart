enum CheckoutStatus { successful, pending, rejected }

class CheckoutResponse {
  const CheckoutResponse({
    required this.status,
    required this.message,
    this.transactionId,
    this.paymentUrl,
  });

  final CheckoutStatus status;
  final String message;
  final String? transactionId;
  final String? paymentUrl;
}
