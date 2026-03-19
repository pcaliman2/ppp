import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle figmaToTextStyle({
  required double fontSize,
  required double lineHeight,
  int fontWeight = 400,
  double letterSpacing = 0,
  String fontFamily = 'inter',
  Color color = Colors.black,
}) {
  // Map font weight to FontWeight
  final weight = FontWeight.values.firstWhere(
    (w) => w.value == fontWeight,
    orElse: () => FontWeight.w400,
  );

  // Calculate height multiplier
  final height = lineHeight / fontSize;

  // Use Google Fonts based on font family
  switch (fontFamily.toLowerCase()) {
    case 'inter':
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    case 'roboto':
      return GoogleFonts.roboto(
        fontSize: fontSize,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    // Add more fonts as needed
    default:
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
  }
}

// Usage:
// final textStyle = figmaToTextStyle(
//   fontSize: 12,
//   lineHeight: 20,
//   fontWeight: 400,
//   letterSpacing: 0,
// );
