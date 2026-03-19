import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class InvertedTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final double maxWidth;

  InvertedTextPainter({
    required this.text,
    required this.textStyle,
    required this.textAlign,
    required this.maxWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle.copyWith(color: Colors.white),
      ),
      textAlign: textAlign,
      textDirection: ui.TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: maxWidth);

    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..blendMode = BlendMode.difference,
    );

    final offset = Offset(
      textAlign == TextAlign.center
          ? (size.width - textPainter.width) / 2
          : textAlign == TextAlign.right
          ? size.width - textPainter.width
          : 0,
      0,
    );

    textPainter.paint(canvas, offset);
    canvas.restore();
  }

  @override
  bool shouldRepaint(InvertedTextPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.textAlign != textAlign ||
        oldDelegate.maxWidth != maxWidth;
  }
}
