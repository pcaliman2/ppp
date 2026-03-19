// BlendedText widget (add this to the same file or import it)
import 'dart:ui' as ui;

import 'package:owa_flutter/useful_widgets/inverted_text_painter.dart';
import 'package:flutter/material.dart';

class BlendedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const BlendedText(this.text, {super.key, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth =
            constraints.maxWidth == double.infinity
                ? 1000.0 // Fallback for unbounded width
                : constraints.maxWidth;

        return CustomPaint(
          painter: InvertedTextPainter(
            text: text,
            textStyle: style ?? TextStyle(),
            textAlign: textAlign ?? TextAlign.start,
            maxWidth: maxWidth,
          ),
          size: _calculateTextSize(text, style ?? TextStyle(), maxWidth),
        );
      },
    );
  }

  Size _calculateTextSize(String text, TextStyle style, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: textAlign ?? TextAlign.start,
      textDirection: ui.TextDirection.ltr,
      maxLines: null,
    );
    textPainter.layout(maxWidth: maxWidth);
    return Size(
      textPainter.width,
      // textPainter.height,
      13, // This avoid display issues like cutted text
    );
  }
}
