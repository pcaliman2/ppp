import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/colors.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/text_styles.dart';

class ActionButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isHighlighted;

  /// Layout
  final double width;
  final double height;
  final EdgeInsetsGeometry margin;

  /// Colors
  final Color borderColor;
  final Color baseColor;
  final Color hoverColor;

  final EdgeInsetsGeometry leadingPadding;

  const ActionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isHighlighted = false,

    /// Defaults
    this.width = 257,
    this.height = 43,
    EdgeInsetsGeometry? margin,
    Color? borderColor,
    Color? baseColor,
    Color? hoverColor,

    /// Hero extras
    this.leadingPadding = const EdgeInsets.only(left: 16),
  }) : margin = margin ?? const EdgeInsets.symmetric(horizontal: 0),
       borderColor = borderColor ?? const Color(0xFF2C2C2C),
       baseColor = baseColor ?? Colors.transparent,
       hoverColor = hoverColor ?? onHoverButtonColor;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.isHighlighted
            ? widget.hoverColor
            : isHovered
            ? widget.hoverColor
            : widget.baseColor;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: widget.width,
          height: widget.height,
          margin:
              widget.margin == const EdgeInsets.symmetric(horizontal: 0)
                  ? EdgeInsets.symmetric(horizontal: SizeConfig.w(2))
                  : widget.margin,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: widget.borderColor, width: 1),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: OWATextStyles.heroMainButtonText,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
