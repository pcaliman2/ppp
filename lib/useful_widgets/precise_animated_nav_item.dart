import 'package:owa_flutter/useful_widgets/blended_text.dart';
import 'package:owa_flutter/useful_widgets/inverted_underline.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PreciseAnimatedNavItem extends StatefulWidget {
  final String text;
  final Color textColor;
  final bool isActive;
  final bool useInvertedText;

  const PreciseAnimatedNavItem({
    super.key,
    required this.text,
    this.textColor = Colors.white,
    this.isActive = false,
    this.useInvertedText = false,
  });

  @override
  State<PreciseAnimatedNavItem> createState() => PreciseAnimatedNavItemState();
}

class PreciseAnimatedNavItemState extends State<PreciseAnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.isActive) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PreciseAnimatedNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else if (!_isHovered) {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() {
    if (!widget.isActive) {
      setState(() {
        _isHovered = true;
      });
      _controller.forward();
    }
  }

  void _onExit() {
    if (!widget.isActive) {
      setState(() {
        _isHovered = false;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontWeight:
          (_isHovered || widget.isActive) ? FontWeight.w500 : FontWeight.w400,
      fontSize: (_isHovered || widget.isActive) ? 9.9 : 10,
      letterSpacing: 0.0,
      height: .95,
      fontStyle: FontStyle.normal,
      color: widget.textColor,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Use BlendedText if useInvertedText is true, otherwise use regular Text
              Row(
                children: [
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      key: _textKey,
                      duration: const Duration(milliseconds: 200),
                      style: style,
                      child:
                          widget.useInvertedText
                              ? BlendedText(
                                widget.text,
                                style: style,
                                textAlign: TextAlign.start,
                              )
                              : Text(widget.text, style: style),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Transform(
                  alignment:
                      !(_controller.status == AnimationStatus.reverse)
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                  transform:
                      Matrix4.identity()..scale(_scaleAnimation.value, 1.0),
                  child:
                      widget.useInvertedText
                          ? InvertedUnderline(
                            width: _getTextWidth(style),
                            height: widget.isActive ? 1.0 : 0.7,
                          )
                          : Container(
                            width: _getTextWidth(style),
                            height: widget.isActive ? 1.0 : 0.7,
                            decoration: BoxDecoration(
                              color: widget.textColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(1),
                              ),
                            ),
                          ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _getTextWidth(TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }
}
