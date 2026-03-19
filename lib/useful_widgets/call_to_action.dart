import 'package:owa_flutter/useful/figma_to_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CallToAction extends StatefulWidget {
  final String text;
  final Color textColor;
  final MainAxisAlignment alignment;
  final Color arrowBackgroundColor;
  final Color hoverBackgroundColor;

  const CallToAction({
    super.key,
    required this.text,
    this.textColor = Colors.white,
    this.alignment = MainAxisAlignment.start,
    this.arrowBackgroundColor = const Color.fromRGBO(216, 200, 187, 1),
    this.hoverBackgroundColor = const Color.fromRGBO(216, 200, 187, 1),
  });

  @override
  State<CallToAction> createState() => CallToActionState();
}

class CallToActionState extends State<CallToAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  bool _isHovered = false;
  late MainAxisAlignment alignment = widget.alignment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() {
    setState(() {
      _isHovered = true;
    });
    _controller.forward();
  }

  void _onExit() {
    setState(() {
      _isHovered = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final normalStyle = figmaToTextStyle(
      fontFamily: 'Inter',
      fontWeight: 400,
      fontSize: 13,
      letterSpacing: 0.0,
      lineHeight: .95,
      color: widget.textColor,
    );

    final hoverStyle = figmaToTextStyle(
      fontFamily: 'Inter',
      fontWeight: 500,
      fontSize: 12.9,
      letterSpacing: 0.0,
      lineHeight: .95,
      color: widget.textColor,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: SizedBox(
        height: 19.600000381469727,
        child: Stack(
          children: [
            // Animated background that expands from left to right
            AnimatedBuilder(
              animation: _widthAnimation,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        height: 19.600000381469727,
                        width: constraints.maxWidth * _widthAnimation.value,
                        color: widget.hoverBackgroundColor,
                      );
                    },
                  ),
                );
              },
            ),
            // Content
            Row(
              mainAxisAlignment: alignment,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 19.600000381469727,
                  height: 19.600000381469727,
                  color: widget.arrowBackgroundColor,
                  alignment: Alignment.center,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 400),
                    alignment: Alignment.center,
                    scale: _isHovered ? 1.5 : 1.0,
                    child: SvgPicture.asset(
                      'assets/icons/arrow_call_to_action.svg',
                      height: 7,
                      fit: BoxFit.fitWidth,
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Stack(
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _isHovered ? 0.0 : 1.0,
                      child: Text(widget.text, style: normalStyle),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _isHovered ? 1.0 : 0.0,
                      child: Text(widget.text, style: hoverStyle),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
