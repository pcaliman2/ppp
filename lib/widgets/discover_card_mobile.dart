import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/size_config.dart';

class DiscoverCardMobile extends StatefulWidget {
  final String imagePath;
  final String title;
  final String buttonText;
  final String description;
  final bool isHighlighted;
  final bool hasBlueAccent;
  final VoidCallback onButtonTap;

  const DiscoverCardMobile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.buttonText,
    required this.description,
    required this.onButtonTap,
    this.isHighlighted = false,
    this.hasBlueAccent = false,
  });

  @override
  State<DiscoverCardMobile> createState() => _DiscoverCardMobileState();
}

class _DiscoverCardMobileState extends State<DiscoverCardMobile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    // final screenRatio = computeScreenRatio(context);
    // final responsivefactor = screenRatio * 0.4;
    final cardWidth = 325.0;
    return SizedBox(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Image container with button overlay
          Container(
            height: 437,
            decoration: BoxDecoration(
              borderRadius:
                  isHovered ? BorderRadius.circular(SizeConfig.w(10)) : null,
            ),
            child: Stack(
              children: [
                // Background image
                ClipRRect(
                  borderRadius:
                      isHovered
                          ? BorderRadius.circular(SizeConfig.w(8))
                          : BorderRadius.zero,
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: ColorFiltered(
                      colorFilter:
                          isHovered
                              ? ColorFilter.mode(
                                Colors.black.withValues(
                                  alpha: 0.3,
                                ), // Adjust alpha for darkness level
                                BlendMode.darken,
                              )
                              : const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              ),
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
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
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
                  ),
                ),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        isHovered
                            ? BorderRadius.circular(SizeConfig.w(10))
                            : null,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),

                // Title text
                Center(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'Basier Square Mono',
                      fontWeight: FontWeight.w400,
                      // fontSize: SizeConfig.t(16),
                      fontSize: 15,
                      height: 1.3,
                      letterSpacing: SizeConfig.t(16) * 0.12,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Button
                Positioned(
                  bottom: SizeConfig.h(24),
                  left: SizeConfig.w(24),
                  right: SizeConfig.w(24),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => isHovered = true),
                    onExit: (_) => setState(() => isHovered = false),
                    child: GestureDetector(
                      onTap: widget.onButtonTap,
                      child: Container(
                        height: SizeConfig.h(40),
                        decoration: BoxDecoration(
                          color:
                              widget.isHighlighted
                                  ? const Color(
                                    0xFFE6FF00,
                                  ) // Yellow for highlighted
                                  : isHovered
                                  ? const Color(0xFFE6FF00) // Yellow on hover
                                  : Colors.transparent,
                          border: Border.all(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(left: SizeConfig.w(16)),
                          child: Text(
                            widget.buttonText,
                            style: TextStyle(
                              fontFamily: 'Arbeit',
                              fontWeight: FontWeight.w400,
                              // fontSize: SizeConfig.t(10),
                              fontSize: 10,
                              color:
                                  widget.isHighlighted || isHovered
                                      ? const Color(0xFF2C2C2C)
                                      : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: SizeConfig.h(20)),

          /// Description text
          Text(
            widget.description,
            style: TextStyle(
              fontFamily: 'Arbeit',
              fontWeight: FontWeight.w400,
              // fontSize: SizeConfig.t(12),
              fontSize: 12,
              height: 1.5,
              letterSpacing: 0,
              color: const Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );
  }
}
