import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

class ResponsiveBreakpoints {
  static const double mobileMax = 599;
  static const double tabletMax = 1023;
  static const double desktopMin = 1024;
}

DeviceType getDeviceType(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  if (width >= ResponsiveBreakpoints.desktopMin) {
    return DeviceType.desktop;
  }

  if (width <= ResponsiveBreakpoints.mobileMax) {
    return DeviceType.mobile;
  }

  return DeviceType.tablet;
}

bool isDesktopFromContext(BuildContext context) {
  return getDeviceType(context) == DeviceType.desktop;
}
