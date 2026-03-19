import 'package:flutter/material.dart';

class OwaFlash {
  OwaFlash._();

  static void showSuccess(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF1F1F1F),
      icon: Icons.check_circle_outline,
      iconColor: const Color(0xFFF1E6C8),
      textColor: const Color(0xFFF5F2EA),
      border: const BorderSide(color: Color(0xFF2B2B2B), width: 1),
      elevation: 10,
    );
  }

  static void showFailure(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFF3A2424),
      icon: Icons.error_outline,
      iconColor: Colors.white,
      textColor: const Color(0xFFF7F2F2),
      border: const BorderSide(color: Color(0xFF553333), width: 1),
      elevation: 10,
    );
  }

  static void showCancellation(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: const Color(0xFFEFEAE0),
      icon: Icons.info_outline,
      iconColor: const Color(0xFF2F2F2F),
      textColor: const Color(0xFF2C2C2C),
      border: const BorderSide(color: Color(0xFFD2C8B8), width: 1),
      elevation: 6,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required BorderSide border,
    required double elevation,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: border,
        ),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
