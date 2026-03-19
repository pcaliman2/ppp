import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AnimatedArrowIcon extends StatefulWidget {
  final double width;
  final double height;
  final String assetPath;
  final bool isHovered;
  final Duration duration;

  const AnimatedArrowIcon({
    super.key,
    required this.width,
    required this.height,
    required this.assetPath,
    required this.isHovered,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedArrowIcon> createState() => _AnimatedArrowIconState();
}

class _AnimatedArrowIconState extends State<AnimatedArrowIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    // Rotation animation (0 to -45 degrees)
    _rotation = Tween<double>(
      begin: 0.0,
      end: -0.785398, // -π/4 radians = -45 degrees
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Set initial state based on isHovered
    _controller.value = 0.0;
  }

  @override
  void didUpdateWidget(AnimatedArrowIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate based on isHovered changes
    if (widget.isHovered != oldWidget.isHovered) {
      if (widget.isHovered) {
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(angle: _rotation.value, child: child);
      },
      child: SvgPicture.asset(
        width: widget.width,
        height: widget.height,
        widget.assetPath,
        colorFilter: ColorFilter.mode(Color(0xFFE6FD45), BlendMode.srcIn),
      ),
    );
  }
}
