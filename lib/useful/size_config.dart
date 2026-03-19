import 'package:flutter/widgets.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double scaleWidth;
  static late double scaleHeight;

  /// Call this once in your app (e.g., in main or first screen build)
  static void init(
    BuildContext context, {
    double figmaWidth = 1440,
    double figmaHeight = 1024,
  }) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;

    scaleWidth = screenWidth / figmaWidth;
    scaleHeight = screenHeight / figmaHeight;
  }

  /// Scale based on width
  static double w(double width) => width * scaleWidth;

  /// Scale based on height
  static double h(double height) => height * scaleHeight;

  /// Scale text (usually width-based looks more natural)
  static double t(double textSize) => textSize * scaleWidth;
}
