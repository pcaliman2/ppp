import 'package:flutter/foundation.dart';

enum CartItemType { membership, service, event }

class CartItem {
  CartItem({
    required this.id,
    required this.type,
    required this.name,
    required this.price,
    required this.qty,
  });

  final String id;
  final CartItemType type;
  final String name;
  final double price;
  int qty;
}

class CartStore extends ChangeNotifier {
  CartStore({List<CartItem>? initialItems})
      : _items = initialItems ?? <CartItem>[];

  final List<CartItem> _items;

  List<CartItem> get items => List<CartItem>.unmodifiable(_items);

  int get totalItems => _items.fold<int>(0, (sum, item) => sum + item.qty);

  double get subtotal =>
      _items.fold<double>(0, (sum, item) => sum + (item.price * item.qty));

  double get total => subtotal;

  void addItem({
    required String id,
    required CartItemType type,
    required String name,
    required double price,
    int qty = 1,
  }) {
    final existingIndex = _items.indexWhere((item) => item.id == id);
    if (existingIndex >= 0) {
      _items[existingIndex].qty += qty;
    } else {
      _items.add(
        CartItem(
          id: id,
          type: type,
          name: name,
          price: price,
          qty: qty,
        ),
      );
    }
    notifyListeners();
  }

  void incrementQty(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _items[index].qty += 1;
    notifyListeners();
  }

  void decrementQty(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return;
    if (_items[index].qty > 1) {
      _items[index].qty -= 1;
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
