import 'package:flutter/material.dart';

class AnimatedMenuIconStack extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double lineThickness;
  final bool isExpanded; // Add this parameter
  final VoidCallback? onTap;

  const AnimatedMenuIconStack({
    super.key,
    this.size = 40.0,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 400),
    this.lineThickness = 2.0,
    this.isExpanded = false, // Default value
    this.onTap,
  });

  @override
  State<AnimatedMenuIconStack> createState() => _AnimatedMenuIconStackState();
}

class _AnimatedMenuIconStackState extends State<AnimatedMenuIconStack>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _topLineRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    // Top line rotation (0 to 90 degrees)
    _topLineRotation = Tween<double>(
      begin: 0.0,
      end: 1.5708, // π/2 radians = 90 degrees
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Set initial state based on isExpanded
    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedMenuIconStack oldWidget) {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final lineWidth = widget.size * 0.6;
          final lineSpacing = widget.size * 0.1;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Top line (rotates)
              Positioned(
                top: widget.size / 2 - lineSpacing,
                child: Transform.rotate(
                  angle: _topLineRotation.value,
                  child: Container(
                    width: lineWidth,
                    height: widget.lineThickness,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(
                        widget.lineThickness / 2,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: widget.size / 2 - lineSpacing,
                child: Container(
                  width: lineWidth,
                  height: widget.lineThickness,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(
                      widget.lineThickness / 2,
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
}
