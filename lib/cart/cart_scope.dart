import 'package:flutter/widgets.dart';
import 'package:owa_flutter/cart/cart_store.dart';

class CartScope extends InheritedNotifier<CartStore> {
  const CartScope({
    super.key,
    required CartStore store,
    required super.child,
  }) : super(notifier: store);

  static CartStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'CartScope not found in context');
    return scope!.notifier!;
  }
}
