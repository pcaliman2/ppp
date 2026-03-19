import 'package:owa_flutter/api/checkout_repository.dart';
import 'package:owa_flutter/models/checkout_request.dart';
import 'package:owa_flutter/models/checkout_response.dart';

class HttpCheckoutRepository implements CheckoutRepository {
  const HttpCheckoutRepository();

  @override
  Future<CheckoutResponse> createCheckout(CheckoutRequest request) async {
    // TODO(api): integrate backend call once endpoint and auth strategy are defined.
    // Suggested flow:
    // 1) POST {apiBaseUrl}/checkout with request.toJson()
    // 2) Parse response payload into CheckoutResponse
    // 3) Handle HTTP and validation errors with app-level error mapping
    throw UnimplementedError('HTTP checkout repository is not wired yet.');
  }
}
