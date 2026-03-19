import 'package:owa_flutter/models/checkout_item.dart';

class CheckoutRequest {
  const CheckoutRequest({
    required this.items,
    required this.buyerName,
    required this.buyerEmail,
    required this.buyerPhone,
    this.buyerCountry,
    this.returnUrl,
    this.cancelUrl,
  });

  final List<CheckoutItem> items;
  final String buyerName;
  final String buyerEmail;
  final String buyerPhone;
  final String? buyerCountry;
  final String? returnUrl;
  final String? cancelUrl;

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'buyerName': buyerName,
      'buyerEmail': buyerEmail,
      'buyerPhone': buyerPhone,
      if (buyerCountry != null && buyerCountry!.isNotEmpty) 'buyerCountry': buyerCountry,
      if (returnUrl != null && returnUrl!.isNotEmpty) 'returnUrl': returnUrl,
      if (cancelUrl != null && cancelUrl!.isNotEmpty) 'cancelUrl': cancelUrl,
    };
  }
}
