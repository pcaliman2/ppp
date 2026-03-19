import 'package:flutter/material.dart';

enum NavItemType { squareMono, circleMono }

class OWAAnimatedNavItem extends StatefulWidget {
  final String text;
  final NavItemType type;
  final Color color;
  final VoidCallback? onTap;

  const OWAAnimatedNavItem({
    super.key,
    required this.text,
    required this.type,
    this.color = Colors.white,
    this.onTap,
  });

  @override
  State<OWAAnimatedNavItem> createState() => _OWAAnimatedNavItemState();
}

class _OWAAnimatedNavItemState extends State<OWAAnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _lineAnim;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _lineAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() {
    if (_isHovered) return;
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _onExit() {
    if (!_isHovered) return;
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  TextStyle _baseTextStyle() {
    // ✅ Match screenshot: fontSize ~10, height ~17px => 1.7
    // (En tu screenshot los items marcaban 17px de alto)
    final common = TextStyle(
      color: widget.color,
      fontSize: 10,
      fontWeight: FontWeight.w400,
      height: 1.7,
      letterSpacing: 0.0,
      decoration: TextDecoration.none,
    );

    switch (widget.type) {
      case NavItemType.squareMono:
        return common.copyWith(fontFamily: 'Basier Square Mono');
      case NavItemType.circleMono:
        return common.copyWith(fontFamily: 'Basier Circle Mono');
    }
  }

  TextStyle _hoverTextStyle() {
    // ✅ Puedes subir weight sin que brinque el underline (lo calculamos con baseStyle)
    return _baseTextStyle().copyWith(fontWeight: FontWeight.w500);
  }

  double _stableTextWidth() {
    // ✅ SIEMPRE con baseStyle para que el underline NO cambie con hover
    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: _baseTextStyle()),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  @override
  Widget build(BuildContext context) {
    final clickable = widget.onTap != null;
    final style = _isHovered ? _hoverTextStyle() : _baseTextStyle();

    final underlineColor = widget.color.withValues(alpha: 0.70);

    // ✅ Hitbox controlado (sin padding gigante)
    // Ajusta si quieres más “aire”, pero así queda más cercano al screenshot.
    return MouseRegion(
      cursor: clickable ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 140),
                style: style,
                child:
                    (widget.text == 'THERAPIES')
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(widget.text),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.north_east,
                              color: widget.color,
                              size: 12,
                            ),
                          ],
                        )
                        : Text(widget.text),
              ),

              const SizedBox(height: 6),

              // ✅ underline animado estable
              AnimatedBuilder(
                animation: _lineAnim,
                builder: (context, _) {
                  return Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.identity()..scale(_lineAnim.value, 1.0),
                    child: Container(
                      width: _stableTextWidth(),
                      height: 1,
                      color: underlineColor,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
