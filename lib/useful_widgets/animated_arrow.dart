import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AnimatedArrow extends StatefulWidget {
  final Duration duration;
  final bool isExpanded; // Add this parameter

  const AnimatedArrow({
    super.key,
    this.duration = const Duration(milliseconds: 400),
    this.isExpanded = false, // Default value
  });

  @override
  State<AnimatedArrow> createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _arrowRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    // Top line rotation (0 to 90 degrees)
    _arrowRotation = Tween<double>(
      begin: 0.0,
      end: 1.5708, // π/2 radians = 90 degrees
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Set initial state based on isExpanded
    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedArrow oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate based on isExpanded changes
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder:
        (context, child) => Transform.rotate(
          angle: _arrowRotation.value,
          child: Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/thin_arrow_right_mobile.svg',
              height: 11.87,
              fit: BoxFit.fitWidth,
              colorFilter: const ColorFilter.mode(
                Color.fromRGBO(28, 28, 28, 1),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
  );
}
