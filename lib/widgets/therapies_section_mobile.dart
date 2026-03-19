import 'package:flutter/material.dart';
import 'package:owa_flutter/widgets/owa_therapies_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/is_desktop_from_context.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/text_styles.dart';
import 'package:owa_flutter/widgets/build_separator.dart';
import 'package:owa_flutter/widgets/headline.dart';
import 'package:owa_flutter/models/owa_specs.dart';

class OWATherapiesSectionMobile extends StatefulWidget {
  const OWATherapiesSectionMobile({super.key});

  @override
  State<OWATherapiesSectionMobile> createState() =>
      _OWATherapiesSectionMobileState();
}

class _OWATherapiesSectionMobileState extends State<OWATherapiesSectionMobile>
    with TickerProviderStateMixin {
  String? _expandedTherapy;

  // Spec state
  OWATherapiesSectionSpec? _spec;
  bool _isLoading = true;
  String? _error;

  // Padding mobile (tu código ya usa 22)
  double get _padX => SizeConfig.w(22);

  // Imagen (ajústalo si tu Figma mobile pide otra altura)
  double get _imageH => SizeConfig.h(240);
  double get _imageRadius => 24;

  // CTA
  double get _ctaW => SizeConfig.w(257);
  double get _ctaH => SizeConfig.h(43);

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
      final spec = await OWATherapiesService.fetchSpec();
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

    final therapiesList = _spec!.data.therapiesList;
    final bookButtonText = _spec!.data.bookButton.text;
    final bookButtonUrl = _spec!.data.bookButton.url;
    final pageDescription = _spec!.data.pageDescription;

    // Map therapyName -> OWATherapyItem for quick lookup
    final Map<String, OWATherapyItem> therapyMap = {
      for (final t in therapiesList) t.therapyName: t,
    };

    final isDesktop = isDesktopFromContext(context);
    final titleToDividerSpacing =
        isDesktop ? SizeConfig.h(14) : SizeConfig.h(34);
    final dividerToSubtitleSpacing =
        isDesktop ? SizeConfig.h(24) : SizeConfig.h(52);
    final headerToContentSpacing =
        isDesktop ? SizeConfig.h(24) : SizeConfig.h(68);

    return Container(
      width: double.infinity,
      color: colors.backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: _padX),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2800 - 2684),

          // ===== Title row: Therapies (izq) + 2.0 (der) =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Headline(
                child: Text('Therapies', style: OWATextStyles.sectionTitle),
              ),
              const Spacer(),
              Text('2.0', style: OWATextStyles.sectionTitleIndex),
            ],
          ),

          SizedBox(height: titleToDividerSpacing),
          buildSeparator(),

          SizedBox(height: dividerToSubtitleSpacing),

          // ===== Description =====
          SizedBox(
            width: double.infinity,
            child: Text(pageDescription, style: OWATextStyles.sectionSubtitle),
          ),

          SizedBox(height: headerToContentSpacing),

          // ===== List =====
          for (final therapy in therapiesList) ...[
            _buildTherapyRow(therapy),
            buildSeparator(),
          ],

          SizedBox(height: SizeConfig.h(28)),

          if (bookButtonUrl.isNotEmpty)
            // ===== CTA bottom =====
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () async {
                  if (bookButtonUrl.isNotEmpty) {
                    final uri = Uri.parse(bookButtonUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  }
                },
                child: Container(
                  width: _ctaW,
                  height: _ctaH,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Text(
                    bookButtonText,
                    style: TextStyle(
                      fontFamily: 'Arbeit',
                      fontWeight: FontWeight.w400,
                      fontSize: SizeConfig.t(10),
                      height: 1.5,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),

          SizedBox(height: SizeConfig.h(60)),
        ],
      ),
    );
  }

  Widget _buildTherapyRow(OWATherapyItem item) {
    final therapy = item.therapyName;
    final isExpanded = _expandedTherapy == therapy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            setState(() {
              _expandedTherapy = isExpanded ? null : therapy;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: SizeConfig.h(18)),
            child: Row(
              children: [
                Text(
                  therapy,
                  style: TextStyle(
                    fontFamily: 'Basier Square Mono',
                    fontWeight: FontWeight.w400,
                    fontSize: SizeConfig.t(12),
                    height: 1.2,
                    letterSpacing: 0.12 * SizeConfig.t(12),
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    isExpanded ? '-' : '+',
                    key: ValueKey(isExpanded),
                    style: TextStyle(
                      fontFamily: 'Basier Square Mono',
                      fontWeight: FontWeight.w400,
                      fontSize: SizeConfig.t(14),
                      height: 1,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints:
                  isExpanded
                      ? const BoxConstraints()
                      : const BoxConstraints(maxHeight: 0),
              child: Padding(
                padding: EdgeInsets.only(bottom: SizeConfig.h(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.therapyDescription,
                      style: TextStyle(
                        fontFamily: 'Arbeit',
                        fontWeight: FontWeight.w300,
                        fontSize: SizeConfig.t(12),
                        height: 18 / 12,
                        color: Colors.black.withValues(alpha: 0.85),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(14)),
                    _buildBenefitsTwoCols(item.benefits),

                    // ===== IMAGE FOR EACH THERAPY =====
                    SizedBox(height: SizeConfig.h(14)),
                    ClipRRect(
                      // borderRadius: BorderRadius.circular(_imageRadius),
                      child: SizedBox(
                        width: double.infinity,
                        height: _imageH,
                        child: Image.network(
                          item.therapyImage.url,
                          fit: BoxFit.cover,
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

  Widget _buildBenefitsTwoCols(List<String> benefits) {
    final left = benefits.take(3).toList();
    final right = benefits.skip(3).take(2).toList();

    final style = TextStyle(
      fontFamily: 'Arbeit',
      fontWeight: FontWeight.w400,
      fontSize: SizeConfig.t(10),
      height: 14 / 10,
      color: Colors.black.withValues(alpha: 0.90),
      decoration: TextDecoration.none,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(left.join('\n'), style: style),
        Text(right.join('\n'), style: style),
      ],
    );
  }
}
