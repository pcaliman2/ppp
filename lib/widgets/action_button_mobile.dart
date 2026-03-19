import 'package:flutter/material.dart';

class ActionButtonMobile extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isHighlighted;

  const ActionButtonMobile({
    super.key,
    required this.text,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  State<ActionButtonMobile> createState() => _ActionButtonMobileState();
}

class _ActionButtonMobileState extends State<ActionButtonMobile> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        widget.isHighlighted
            ? const Color(0xFFE6FF00)
            : isPressed
            ? const Color(0xFFE6FF00)
            : Colors.transparent;

    final borderColor = const Color(0xFF2C2C2C);

    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap:
          widget
              .onTap, // ✅ Esto ya estaba bien, ahora recibe la función correcta
      child: Container(
        width: double.infinity,
        height: 43,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.text,
          style: TextStyle(
            fontFamily: 'Arbeit',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            height: 1.5,
            letterSpacing: 0,
            color: const Color(0xFF2C2C2C),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
