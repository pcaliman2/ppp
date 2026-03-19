import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FadeInWidget extends StatefulWidget {
  final Widget child;

  const FadeInWidget({super.key, required this.child});

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    /// Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    /// Text fade animation - delayed start
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    /// Text slide animation - subtle upward motion with reduced distance
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(
        0,
        0.1,
      ), // Changed from 0.3 to 0.1 for shorter distance
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    // Trigger animation when widget is at least 30% visible
    if (!_hasAnimated && info.visibleFraction > 0.3) {
      _hasAnimated = true;
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _textController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? Key('headline_${widget.child.hashCode}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedBuilder(
        animation: _textFadeAnimation,
        builder:
            (context, child) => FadeTransition(
              opacity: _textFadeAnimation,
              child: SlideTransition(
                position: _textSlideAnimation,
                child: widget.child,
              ),
            ),
      ),
    );
  }
}

class HorizontalFadeInWidget extends StatefulWidget {
  final Widget child;

  const HorizontalFadeInWidget({super.key, required this.child});

  @override
  State<HorizontalFadeInWidget> createState() => _HorizontalFadeInWidgetState();
}

class _HorizontalFadeInWidgetState extends State<HorizontalFadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _widthAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _widthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_hasAnimated && info.visibleFraction > 0.3) {
      _hasAnimated = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('horizontal_fade_${widget.child.hashCode}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedBuilder(
        animation: _controller,
        builder:
            (context, child) => FadeTransition(
              opacity: _fadeAnimation,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _widthAnimation.value,
                  child: widget.child,
                ),
              ),
            ),
      ),
    );
  }
}
