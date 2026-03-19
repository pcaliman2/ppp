import 'package:flutter/widgets.dart';

class SmoothDesktopScrollPhysics extends ClampingScrollPhysics {
  const SmoothDesktopScrollPhysics({super.parent});

  @override
  SmoothDesktopScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SmoothDesktopScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Keep native desktop wheel input from jumping too aggressively while
    // still allowing draggable scrollbars and direct user interaction.
    return offset * 0.08;
  }
}
