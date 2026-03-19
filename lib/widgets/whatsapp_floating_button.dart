import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppFloatingButton extends StatefulWidget {
  const WhatsAppFloatingButton({super.key});

  @override
  State<WhatsAppFloatingButton> createState() => _WhatsAppFloatingButtonState();
}

class _WhatsAppFloatingButtonState extends State<WhatsAppFloatingButton> {
  static final Uri _whatsAppUri = Uri.parse(
    'https://wa.me/5215610297637?text=Hello%20OWA!%20I%20would%20like%20to%20know%20more%20about%20your%20services.',
  );

  bool _isHovered = false;

  Future<void> _openWhatsApp() async {
    final launched = await launchUrl(_whatsAppUri, mode: LaunchMode.externalApplication);

    if (!mounted || launched) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open WhatsApp right now. Please try again.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _openWhatsApp,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1F1F1F),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
