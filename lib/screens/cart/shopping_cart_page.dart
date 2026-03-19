import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/widgets/cart_panel.dart';

class ShoppingCartPage extends StatelessWidget {
  const ShoppingCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: colors.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: const SafeArea(child: CartPanel()),
    );
  }
}
