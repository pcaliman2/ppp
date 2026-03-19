import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Headline extends StatefulWidget {
  final Text child;

  const Headline({super.key, required this.child});

  @override
  State<Headline> createState() => _HeadlineState();
}

class _HeadlineState extends State<Headline> with TickerProviderStateMixin {
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

    /// Text slide animation - subtle upward motion
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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
      key: Key('headline_${widget.child.hashCode}'),
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
