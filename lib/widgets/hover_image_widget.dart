import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:owa_flutter/useful/size_config.dart';

class HoverImageWidget extends StatefulWidget {
  final String imagePath;
  final bool isDesktop;

  const HoverImageWidget({
    super.key,
    required this.imagePath,
    required this.isDesktop,
  });

  @override
  State<HoverImageWidget> createState() => _HoverImageWidgetState();
}

class _HoverImageWidgetState extends State<HoverImageWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: SizeConfig.w(widget.isDesktop ? 264.77 : 180),
        height:
            widget.isDesktop
                ? 270.76
                : 180, // SizeConfig.h(widget.isDesktop ? 270.76 : 190),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.w(9.99)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SizeConfig.w(9.99)),
          child: Stack(
            children: [
              // Base Image
              Positioned.fill(
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF2C2C2C),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo,
                              color: Colors.white.withValues(alpha: 0.6),
                              size: SizeConfig.w(40),
                            ),
                            SizedBox(height: SizeConfig.h(8)),
                            Text(
                              'Image',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: SizeConfig.t(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Hover Overlay with Icon
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isHovered ? 1.0 : 0.0,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: Center(
                    child: Container(
                      width: SizeConfig.w(60),
                      height: SizeConfig.w(60),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(SizeConfig.w(12)),
                      ),
                      alignment: Alignment.center,
                      child: FaIcon(
                        FontAwesomeIcons.instagram,
                        color: Colors.white,
                        size: SizeConfig.w(32),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
