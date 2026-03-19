import 'package:flutter/widgets.dart';

double computeScreenRatio(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final screenRatio = screenSize.height / screenSize.width;
  return screenRatio;
}
