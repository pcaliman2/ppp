import 'package:owa_flutter/models/checkout_request.dart';
import 'package:owa_flutter/models/checkout_response.dart';

abstract class CheckoutRepository {
  Future<CheckoutResponse> createCheckout(CheckoutRequest request);
}
