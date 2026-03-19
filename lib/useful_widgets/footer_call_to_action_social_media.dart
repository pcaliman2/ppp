import 'package:owa_flutter/useful/text_styles.dart';
import 'package:flutter/material.dart';

class FooterCallToActionSocialMedia extends StatefulWidget {
  final String text;

  const FooterCallToActionSocialMedia({super.key, required this.text});

  @override
  State<FooterCallToActionSocialMedia> createState() =>
      FooterCallToActionSocialMediaState();
}

class FooterCallToActionSocialMediaState
    extends State<FooterCallToActionSocialMedia>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() {
    setState(() {
      _isHovered = true;
    });
    _controller.forward();
  }

  void _onExit() {
    setState(() {
      _isHovered = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => _onEnter(),
    onExit: (_) => _onExit(),
    child: Stack(
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: _isHovered ? 0.0 : 1.0,
          child: Text(widget.text, style: OWATextStyles.footerCallToActionText),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: _isHovered ? 1.0 : 0.0,
          child: Text(
            widget.text,
            style: OWATextStyles.footerCallToActionTextHover,
          ),
        ),
      ],
    ),
  );
}
