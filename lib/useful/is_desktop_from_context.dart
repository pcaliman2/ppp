import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  static const double mobileMax = 599;
  static const double tabletMax = 1023;
  static const double desktopMin = 1024;
}

double _effectiveWidth(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  final logicalWidth = mediaQuery.size.width;

  // En web móvil/tablet (Safari iPhone, Chrome Android, etc.)
  // NO debemos multiplicar por devicePixelRatio.
  if (kIsWeb &&
      defaultTargetPlatform != TargetPlatform.iOS &&
      defaultTargetPlatform != TargetPlatform.android) {
    return logicalWidth * mediaQuery.devicePixelRatio;
  }

  return logicalWidth;
}

bool isDesktopFromContext(BuildContext context) {
  final width = _effectiveWidth(context);
  return width >= ResponsiveBreakpoints.desktopMin;
}
