import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:owa_flutter/discover_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/is_desktop_from_context.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/widgets/discover_card_image_from_url.dart';
import 'package:owa_flutter/widgets/fade_in_widget.dart';
import 'package:owa_flutter/widgets/headline.dart';
import 'package:owa_flutter/models/owa_specs.dart';

class OWADiscoverSectionMobile extends StatefulWidget {
  const OWADiscoverSectionMobile({super.key});

  @override
  State<OWADiscoverSectionMobile> createState() =>
      _OWADiscoverSectionMobileState();
}

class _OWADiscoverSectionMobileState extends State<OWADiscoverSectionMobile> {
  int currentIndex = 0;

  // Spec state
  OWADiscoverSectionSpec? _spec;
  bool _isLoading = true;
  String? _error;

  // ==========================
  // ===== LIFECYCLE =====
  // ==========================

  @override
  void initState() {
    super.initState();
    _loadSpec();
  }

  Future<void> _loadSpec() async {
    try {
      final spec = await OWADiscoverService.fetchSpec();
      setState(() {
        _spec = spec;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _previousCard(int length) {
    setState(() {
      currentIndex = currentIndex > 0 ? currentIndex - 1 : length - 1;
    });
  }

  void _nextCard(int length) {
    setState(() {
      currentIndex = currentIndex < length - 1 ? currentIndex + 1 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_error != null) return const SizedBox.shrink();

    final cards = _spec!.data.discoverSections;
    final pageDescription = _spec!.data.pageDescription;
    final currentCard = cards[currentIndex];

    final isDesktop = isDesktopFromContext(context);
    final titleToSubtitleSpacing =
        isDesktop ? SizeConfig.h(20) : SizeConfig.h(56);
    final headerToContentSpacing =
        isDesktop ? SizeConfig.h(80) : SizeConfig.h(144);

    return Container(
      width: double.infinity,
      color: colors.backgroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(20),
        vertical: SizeConfig.h(80),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side - Title
          Headline(
            child: Text(
              'DISCOVER OWA',
              style: TextStyle(
                fontFamily: 'Basier Square Mono',
                fontWeight: FontWeight.w400,
                // fontSize: SizeConfig.t(19),
                fontSize: 19,
                height: 1.51,
                letterSpacing: SizeConfig.t(19) * 0.12,
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ),

          SizedBox(height: titleToSubtitleSpacing),

          // Right side - Description
          Headline(
            child: Text(
              pageDescription,
              style: TextStyle(
                fontFamily: 'Arbeit',
                fontWeight: FontWeight.w300,
                // fontSize: SizeConfig.t(15),
                fontSize: 15,
                height: 24 / 15,
                letterSpacing: 0,
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ),

          SizedBox(height: headerToContentSpacing),

          // Single card container
          FadeInWidget(
            child: DiscoverCard(
              buttonUrl: currentCard.cardLinkUrl,
              imagePath: currentCard.cardBackgroundImage.url,
              title: currentCard.cardTitle,
              buttonText: currentCard.cardLinkText,
              description: currentCard.cardDescription,
              onButtonTap: () async {
                final url = currentCard.cardLinkUrl;
                if (url.isNotEmpty) {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
              cardWidth: double.infinity,
              borderRadius: 10,
              useAnimatedRadius: false,
            ),
          ),

          SizedBox(height: SizeConfig.h(40)),

          // Navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _previousCard(cards.length),
                child: SvgPicture.asset('assets/icons/thin_arrow_left.svg'),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () => _nextCard(cards.length),
                child: SvgPicture.asset('assets/icons/thin_arrow_right.svg'),
              ),

              // // Previous button
              // GestureDetector(
              //   onTap: _previousCard,
              //   child: Container(
              //     // width: SizeConfig.w(40),
              //     // height: SizeConfig.w(40),
              //     width: 40,
              //     height: 40,
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       border: Border.all(
              //         color: const Color(0xFF2C2C2C),
              //         width: 1.5,
              //       ),
              //     ),
              //     child: Padding(
              //       padding: const EdgeInsets.only(left: 4.0),
              //       child: Icon(
              //         Icons.arrow_back_ios,
              //         // size: SizeConfig.t(16),
              //         size: 16,
              //         color: const Color(0xFF2C2C2C),
              //       ),
              //     ),
              //   ),
              // ),

              // SizedBox(width: 20),

              // // Next button
              // GestureDetector(
              //   onTap: _nextCard,
              //   child: Container(
              //     // width: SizeConfig.w(40),
              //     // height: SizeConfig.w(40),
              //     width: 40,
              //     height: 40,
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       border: Border.all(
              //         color: const Color(0xFF2C2C2C),
              //         width: 1.5,
              //       ),
              //     ),
              //     child: Icon(
              //       Icons.arrow_forward_ios,
              //       // size: SizeConfig.t(16),
              //       size: 16,
              //       color: const Color(0xFF2C2C2C),
              //     ),
              //   ),
              // ),
              Spacer(),
              // Page indicator
              Text(
                '${(currentIndex + 1).toString().padLeft(2, '0')} / ${cards.length.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontFamily: 'Basier Square Mono',
                  fontWeight: FontWeight.w400,
                  fontSize: 9.0,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
