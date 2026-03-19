import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  static const double mobileMax = 599;
  static const double tabletMax = 1023;
  static const double desktopMin = 1024;
}

double _effectiveWidth(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);

  if (kIsWeb) {
    return mediaQuery.size.width * mediaQuery.devicePixelRatio;
  }

  return mediaQuery.size.width;
}

bool isDesktopFromContext(BuildContext context) {
  final width = _effectiveWidth(context);
  return width >= ResponsiveBreakpoints.desktopMin;
}
