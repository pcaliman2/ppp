import 'package:owa_flutter/cart/cart_store.dart';

class CheckoutItem {
  const CheckoutItem({
    required this.type,
    required this.id,
    required this.title,
    required this.price,
    required this.qty,
    this.metadata,
  });

  final CartItemType type;
  final String id;
  final String title;
  final double price;
  final int qty;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'id': id,
      'title': title,
      'price': price,
      'qty': qty,
      if (metadata != null) 'metadata': metadata,
    };
  }
}
