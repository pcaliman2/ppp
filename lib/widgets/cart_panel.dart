import 'package:flutter/material.dart';
import 'package:owa_flutter/cart/cart_scope.dart';
import 'package:owa_flutter/cart/cart_store.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/text_styles.dart';

String _formatCartCurrency(double value) => '\$${value.toStringAsFixed(2)} MXN';

class CartPanel extends StatelessWidget {
  const CartPanel({
    super.key,
    this.inDrawer = false,
  });

  final bool inDrawer;

  @override
  Widget build(BuildContext context) {
    final cartStore = CartScope.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: cartStore,
      builder: (context, _) {
        return Container(
          color: colors.backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SizeConfig.w(20),
                  SizeConfig.h(18),
                  SizeConfig.w(22),
                  SizeConfig.h(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Shopping Cart',
                        style: textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF232323),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (inDrawer)
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        alignment: Alignment.topRight,
                        splashRadius: 18,
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF2D2D2D),
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: cartStore.items.isEmpty
                    ? Center(
                        child: Text(
                          'Your cart is empty.',
                          style: textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF545454),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(20)),
                        itemCount: cartStore.items.length,
                        itemBuilder: (context, index) {
                          final item = cartStore.items[index];
                          return _CartItemTile(
                            item: item,
                            cartStore: cartStore,
                            showDivider: true,
                          );
                        },
                      ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  SizeConfig.w(20),
                  SizeConfig.h(12),
                  SizeConfig.w(20),
                  SizeConfig.h(20),
                ),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFCFC6BA))),
                ),
                child: Column(
                  children: [
                    _SummaryRow(label: 'Subtotal', value: cartStore.subtotal),
                    SizedBox(height: SizeConfig.h(6)),
                    _SummaryRow(label: 'Total', value: cartStore.total, isBold: true),
                    SizedBox(height: SizeConfig.h(12)),
                    _CompleteSaleButton(inDrawer: inDrawer),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartItemTile extends StatefulWidget {
  const _CartItemTile({
    required this.item,
    required this.cartStore,
    this.showDivider = true,
  });

  final CartItem item;
  final CartStore cartStore;
  final bool showDivider;

  @override
  State<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<_CartItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final item = widget.item;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: EdgeInsets.only(top: SizeConfig.h(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.w(2),
                right: SizeConfig.w(2),
                bottom: SizeConfig.h(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: textTheme.titleMedium?.copyWith(
                            color: _isHovered ? const Color(0xFF1F1F1F) : const Color(0xFF262626),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(3)),
                        Text(
                          _typeLabel(item.type),
                          style: textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF5D5D5D),
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(10)),
                        Text(
                          _formatCartCurrency(item.price),
                          style: textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF2F2F2F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => widget.cartStore.removeItem(item.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    alignment: Alignment.topRight,
                    splashRadius: 18,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.showDivider)
              Divider(
                height: SizeConfig.h(18),
                thickness: 0.7,
                color: const Color(0xFF7A7A7A).withValues(alpha: 0.22),
              ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(CartItemType type) {
    switch (type) {
      case CartItemType.membership:
        return 'Membership';
      case CartItemType.service:
        return 'Service';
      case CartItemType.event:
        return 'Event';
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final double value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: const Color(0xFF292929),
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
        );
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(_formatCartCurrency(value), style: style),
      ],
    );
  }
}

class _CompleteSaleButton extends StatefulWidget {
  const _CompleteSaleButton({required this.inDrawer});

  final bool inDrawer;

  @override
  State<_CompleteSaleButton> createState() => _CompleteSaleButtonState();
}

class _CompleteSaleButtonState extends State<_CompleteSaleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFF1F1F1F);
    const hoverColor = Color(0xFF333333);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (widget.inDrawer) {
            Navigator.of(context).pop();
          }
          Navigator.of(context).pushNamed('/checkout');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: 48,
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.w(2)),
          decoration: BoxDecoration(
            color: _isHovered ? hoverColor : baseColor,
            border: Border.all(color: baseColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'COMPLETE SALE',
                style: OWATextStyles.heroMainButtonText,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
