import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/size_config.dart';

class MembershipCardMobile extends StatefulWidget {
  final String number;
  final String title;
  final String imagePath;
  final String description;
  final Color buttonColor;
  final Color buttonTextColor;

  const MembershipCardMobile({
    super.key,
    required this.number,
    required this.title,
    required this.imagePath,
    required this.description,
    required this.buttonColor,
    required this.buttonTextColor,
  });

  @override
  _MembershipCardMobileState createState() => _MembershipCardMobileState();
}

class _MembershipCardMobileState extends State<MembershipCardMobile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cardWidth = 325.0;
    return SizedBox(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number
          Text(
            widget.number,
            style: TextStyle(
              fontFamily: 'Basier Square Mono',
              fontWeight: FontWeight.w400,
              fontSize: 9,
              height: 0.9,
              letterSpacing: 0.12,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          SizedBox(height: SizeConfig.h(16)),

          // Image Container with overlay
          Container(
            height: 437,
            decoration: BoxDecoration(
              borderRadius:
                  isHovered ? BorderRadius.circular(SizeConfig.w(10)) : null,
            ),
            child: Stack(
              children: [
                // Background Image
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
                                Colors.black.withValues(alpha: 0.3),
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
                                    size: 40,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Image',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 12,
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

                // Dark overlay
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

                /// Title
                Center(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'Basier Square Mono',
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      height: 1.3,
                      letterSpacing: 15 * 0.12,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                /// Button
                Positioned(
                  bottom: SizeConfig.h(24),
                  left: SizeConfig.w(24),
                  right: SizeConfig.w(24),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => isHovered = true),
                    onExit: (_) => setState(() => isHovered = false),
                    child: GestureDetector(
                      onTap: () {
                        // Handle get started action
                      },
                      child: Container(
                        height: SizeConfig.h(26),
                        decoration: BoxDecoration(
                          color:
                              isHovered
                                  ? const Color(0xFFE6FF00) // Yellow on hover
                                  : widget.buttonColor,
                          border: Border.all(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(left: SizeConfig.w(16)),
                          child: Text(
                            'GET STARTED',
                            style: TextStyle(
                              fontFamily: 'Arbeit',
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                              color:
                                  isHovered
                                      ? const Color(0xFF2C2C2C)
                                      : widget.buttonTextColor,
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

          // Description
          Text(
            widget.description,
            style: TextStyle(
              fontFamily: 'Arbeit',
              fontWeight: FontWeight.w400,
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
