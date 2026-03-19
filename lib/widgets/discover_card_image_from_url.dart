import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/text_styles.dart';

class DiscoverCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String buttonText;
  final String buttonUrl;
  final String description;
  final bool isHighlighted;
  final bool hasBlueAccent;
  final VoidCallback onButtonTap;
  final double? cardWidth;
  final double? cardHeight;
  final double borderRadius;
  final bool useAnimatedRadius;

  const DiscoverCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.buttonText,
    required this.description,
    required this.onButtonTap,
    this.isHighlighted = false,
    this.hasBlueAccent = false,
    this.cardWidth,
    this.cardHeight,
    this.borderRadius = 8,
    this.useAnimatedRadius = true,
    required this.buttonUrl,
  });

  @override
  State<DiscoverCard> createState() => _DiscoverCardState();
}

class _DiscoverCardState extends State<DiscoverCard>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;

  // ─── Corner radius animation (transferred from MembershipTile) ────────────
  late AnimationController _cornerController;
  late Animation<double> _cornerRadiusAnim;

  @override
  void initState() {
    super.initState();

    _cornerController = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _cornerRadiusAnim = CurvedAnimation(
      parent: _cornerController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );

    _cornerController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cornerController.dispose();
    super.dispose();
  }

  /// Interpolated radius: 0 (square) → SizeConfig.w(8) (rounded)
  double get _currentRadius =>
      lerpDouble(0, widget.borderRadius, _cornerRadiusAnim.value)!;

  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.cardWidth ?? SizeConfig.w(320);
    final cardHeight = widget.cardHeight ?? 410.0;
    final cardRadius =
        widget.useAnimatedRadius ? _currentRadius : widget.borderRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image container with overlay
        MouseRegion(
          onEnter: (_) {
            setState(() => isHovered = true);
            _cornerController.forward();
          },
          onExit: (_) {
            setState(() => isHovered = false);
            _cornerController.reverse();
          },
          child: GestureDetector(
            onTap: widget.onButtonTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cardRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(cardRadius),
                child: Stack(
                  children: [
                    /// Background image with zoom effect
                    Positioned.fill(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        scale: isHovered ? 1.02 : 1.0,
                        child: Image.network(
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
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
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

                    // Gradient overlay (always visible)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
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
                    ),

                    // Bottom overlay with blur and expanding content
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(cardRadius),
                        child: BackdropFilter(
                          blendMode: BlendMode.srcOver,
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.w(22),
                              vertical:
                                  isHovered
                                      ? SizeConfig.h(8 * 3)
                                      : SizeConfig.h(8),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(cardRadius),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title (always visible)
                                Text(
                                  widget.title,
                                  style: OWATextStyles.discoverCardTitle,
                                ),

                                // Description and Button Text (visible on hover)
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeInOut,
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 600),
                                    opacity: isHovered ? 1.0 : 0.0,
                                    child:
                                        isHovered
                                            ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: SizeConfig.h(16),
                                                ),

                                                // Description text
                                                Text(
                                                  widget.description,
                                                  style:
                                                      OWATextStyles
                                                          .discoverCardSubtitle,
                                                ),

                                                SizedBox(
                                                  height: SizeConfig.h(20),
                                                ),
                                                if (widget.buttonUrl.isNotEmpty)
                                                  // Button text with arrow
                                                  Row(
                                                    children: [
                                                      Text(
                                                        widget.buttonText,
                                                        style:
                                                            OWATextStyles
                                                                .discoverCardFooterText,
                                                      ),
                                                      SizedBox(
                                                        width: SizeConfig.w(12),
                                                      ),
                                                      // Animated Arrow
                                                      AnimatedRotation(
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 400,
                                                            ),
                                                        turns:
                                                            isHovered
                                                                ? 0.125 * 7
                                                                : 0,
                                                        child: Icon(
                                                          Icons.arrow_forward,
                                                          size: SizeConfig.w(
                                                            14,
                                                          ),
                                                          color: const Color(
                                                            0xFFE6FF00,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            )
                                            : const SizedBox.shrink(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
