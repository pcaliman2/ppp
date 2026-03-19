class CartDummyItem {
  const CartDummyItem({
    required this.name,
    required this.price,
    required this.qty,
  });

  final String name;
  final double price;
  final int qty;
}

const List<CartDummyItem> kCartDummyItems = [
  CartDummyItem(name: 'OWA Membership Basic', price: 49.0, qty: 1),
  CartDummyItem(name: 'Therapy Session', price: 120.0, qty: 2),
  CartDummyItem(name: 'Breathwork Class', price: 35.0, qty: 1),
];
