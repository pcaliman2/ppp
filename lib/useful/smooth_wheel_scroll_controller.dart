import 'dart:ui' show clampDouble;

import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

class SmoothWheelScrollController extends ScrollController {
  SmoothWheelScrollController({
    this.duration = const Duration(milliseconds: 140),
    this.curve = Curves.easeOutCubic,
    this.wheelDeltaScale = 1.0,
  });

  final Duration duration;
  final Curve curve;
  final double wheelDeltaScale;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _SmoothWheelScrollPosition(
      physics: physics,
      context: context,
      oldPosition: oldPosition,
      duration: duration,
      curve: curve,
      wheelDeltaScale: wheelDeltaScale,
    );
  }
}

class _SmoothWheelScrollPosition extends ScrollPositionWithSingleContext {
  _SmoothWheelScrollPosition({
    required super.physics,
    required super.context,
    super.oldPosition,
    required this.duration,
    required this.curve,
    required this.wheelDeltaScale,
  });

  final Duration duration;
  final Curve curve;
  final double wheelDeltaScale;
  double? _targetPixels;
  bool _isAnimatingWheel = false;

  @override
  void pointerScroll(double delta) {
    if (delta == 0) {
      goBallistic(0);
      return;
    }

    final basePixels = _targetPixels ?? pixels;
    final targetPixels = clampDouble(
      basePixels + (delta * wheelDeltaScale),
      minScrollExtent,
      maxScrollExtent,
    );

    if ((targetPixels - basePixels).abs() < 0.5) return;

    _targetPixels = targetPixels;
    if (_isAnimatingWheel) return;
    _animateToWheelTarget();
  }

  void _animateToWheelTarget() {
    final target = _targetPixels;
    if (target == null) return;

    _isAnimatingWheel = true;
    animateTo(target, duration: duration, curve: curve).whenComplete(() {
      _isAnimatingWheel = false;

      final latestTarget = _targetPixels;
      if (latestTarget == null) {
        goBallistic(0);
        return;
      }

      if ((latestTarget - pixels).abs() < 1.0) {
        _targetPixels = null;
        goBallistic(0);
        return;
      }

      _animateToWheelTarget();
    });
  }
}
