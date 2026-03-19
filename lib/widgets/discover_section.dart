import 'package:flutter/material.dart';
import 'package:owa_flutter/discover_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/text_styles.dart';
import 'package:owa_flutter/widgets/build_separator.dart';
import 'package:owa_flutter/widgets/discover_card_image_from_url.dart';
import 'package:owa_flutter/widgets/fade_in_widget.dart';
import 'package:owa_flutter/widgets/headline.dart';
import 'package:owa_flutter/models/owa_specs.dart';

class OWADiscoverSection extends StatefulWidget {
  const OWADiscoverSection({super.key});

  @override
  State<OWADiscoverSection> createState() => _OWADiscoverSectionState();
}

class _OWADiscoverSectionState extends State<OWADiscoverSection> {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_error != null) return const SizedBox.shrink();

    final cards = _spec!.data.discoverSections;
    final pageDescription = _spec!.data.pageDescription;

    return Container(
      width: SizeConfig.w(1440),
      color: colors.backgroundColor, // Same as body background
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(42)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side - Title
              SizedBox(
                width: SizeConfig.w(330),
                child: Headline(
                  child: Text(
                    'DISCOVER OWA',
                    style: OWATextStyles.sectionTitle,
                  ),
                ),
              ),

              // Right side - Index
              Headline(
                child: Text('1.0', style: OWATextStyles.sectionTitleIndex),
              ),
            ],
          ),

          /// Spacer
          SizedBox(height: SizeConfig.h(1229.39 - (1186.44 + 30))),

          /// Divider
          buildSeparator(),

          /// Spacer
          SizedBox(height: SizeConfig.h(1288.51 - 1229.39)),

          SizedBox(
            width: SizeConfig.w(521.93017578125),
            // height: SizeConfig.h(78),
            height: 78.0,
            child: Headline(
              child: Text(
                pageDescription,
                style: OWATextStyles.sectionSubtitle,
              ),
            ),
          ),

          /// Spacer
          SizedBox(height: SizeConfig.h(80)),

          /// Cards grid
          FadeInWidget(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  Expanded(
                    child: DiscoverCard(
                      imagePath: cards[i].cardBackgroundImage.url,
                      title: cards[i].cardTitle,
                      buttonText: cards[i].cardLinkText,
                      description: cards[i].cardDescription,
                      buttonUrl: cards[i].cardLinkUrl,
                      onButtonTap: () async {
                        final url = cards[i].cardLinkUrl;
                        if (url.isNotEmpty) {
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        }
                      },
                    ),
                  ),
                  if (i < cards.length - 1) SizedBox(width: SizeConfig.w(20)),
                ],
              ],
            ),
          ),

          /// Spacer
          SizedBox(height: 2035 - (1476.78 + 410.18)),
        ],
      ),
    );
  }
}
