import 'package:owa_flutter/api/checkout_repository.dart';
import 'package:owa_flutter/models/checkout_request.dart';
import 'package:owa_flutter/models/checkout_response.dart';

const CheckoutStatus kMockCheckoutDefaultStatus = CheckoutStatus.pending;

class MockCheckoutRepository implements CheckoutRepository {
  const MockCheckoutRepository();

  @override
  Future<CheckoutResponse> createCheckout(CheckoutRequest request) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    switch (kMockCheckoutDefaultStatus) {
      case CheckoutStatus.successful:
        return const CheckoutResponse(
          status: CheckoutStatus.successful,
          message: 'Payment confirmed.',
          transactionId: 'TX-MOCK-1001',
        );
      case CheckoutStatus.rejected:
        return const CheckoutResponse(
          status: CheckoutStatus.rejected,
          message: 'Payment rejected.',
          transactionId: 'TX-MOCK-1001',
        );
      case CheckoutStatus.pending:
        return const CheckoutResponse(
          status: CheckoutStatus.pending,
          message: 'Payment is pending confirmation.',
          transactionId: 'TX-MOCK-1001',
        );
    }
  }
}
