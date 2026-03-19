import 'package:flutter/material.dart';

class InvertedUnderline extends StatelessWidget {
  final double width;
  final double height;

  const InvertedUnderline({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: InvertedUnderlinePainter(height: height),
    );
  }
}

class InvertedUnderlinePainter extends CustomPainter {
  final double height;

  InvertedUnderlinePainter({required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..blendMode = BlendMode.difference,
    );

    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(1),
    );

    canvas.drawRRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(InvertedUnderlinePainter oldDelegate) {
    return oldDelegate.height != height;
  }
}
