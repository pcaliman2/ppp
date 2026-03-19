import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:owa_flutter/memberships_service.dart';
import 'package:owa_flutter/models/owa_specs.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/is_desktop_from_context.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/widgets/fade_in_widget.dart';
import 'package:owa_flutter/widgets/headline.dart';
import 'package:owa_flutter/widgets/membership_card_image_from_url.dart';
import 'package:owa_flutter/widgets/membership_spec.dart';

class MembershipsSectionMobile extends StatefulWidget {
  const MembershipsSectionMobile({super.key});

  @override
  State<MembershipsSectionMobile> createState() =>
      _MembershipsSectionMobileState();
}

class _MembershipsSectionMobileState extends State<MembershipsSectionMobile> {
  int currentIndex = 0;

  // Spec state
  OWAMembershipsSectionSpec? _spec;
  bool _isLoading = true;
  String? _error;

  final List<String> _commonBenefits = const [
    '- 2 sauna visits/semana',
    '- 1 hiperbarica/semana',
    '- 30 min masaje mensual.',
  ];

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
      final spec = await OWAMembershipsService.fetchSpec();
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

  // Maps an OWAMembershipItem from the spec into the existing MembershipSpec model
  MembershipSpec _toMembershipSpec(OWAMembershipItem item) {
    return MembershipSpec(
      title: item.membershipTitle,
      price: item.price,
      imagePath: item.backgroundImage.url,
      mainDescription: item.description,
      benefits: item.benefits,
      borderRadiusValue: 12.0,
      onTap: () => print("Tap ${item.membershipTitle}"),
    );
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

    final specs = _spec!.data.membershipsList.map(_toMembershipSpec).toList();
    final pageDescription = _spec!.data.pageDescription;
    final current = specs[currentIndex];

    final isDesktop = isDesktopFromContext(context);
    final titleToSubtitleSpacing =
        isDesktop ? SizeConfig.h(20) : SizeConfig.h(56);
    final headerToContentSpacing =
        isDesktop ? SizeConfig.h(80) : SizeConfig.h(144);

    return Container(
      width: double.infinity,
      color: colors.backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 27, vertical: SizeConfig.h(80)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Headline(
            child: Text(
              'MEMBERSHIPS',
              style: TextStyle(
                fontFamily: 'Basier Square Mono',
                fontWeight: FontWeight.w400,
                fontSize: 19,
                height: 1.51,
                letterSpacing: 19 * 0.12,
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ),

          SizedBox(height: titleToSubtitleSpacing),

          // Description Text
          Headline(
            child: Text(
              pageDescription,
              style: TextStyle(
                fontFamily: 'Arbeit',
                fontWeight: FontWeight.w300,
                fontSize: 15,
                height: 24 / 15,
                letterSpacing: 0,
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ),

          SizedBox(height: headerToContentSpacing),

          // ✅ Using MembershipCard with individual properties from MembershipSpec
          FadeInWidget(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: MembershipCard(
                    title: current.title,
                    price: current.price,
                    imagePath: current.imagePath,
                    onTap: current.onTap,
                    borderRadiusValue: current.borderRadiusValue ?? 10.0,
                  ),
                ),
                SizedBox(height: SizeConfig.h(16)),
                Text(
                  current.mainDescription,
                  style: TextStyle(
                    fontFamily: 'Arbeit',
                    fontWeight: FontWeight.w300,
                    fontSize: SizeConfig.t(11),
                    height: 1.67,
                    letterSpacing: 0,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
                SizedBox(height: SizeConfig.h(10)),
                ...((current.benefits ?? _commonBenefits).map(
                  (benefit) => Padding(
                    padding: EdgeInsets.only(bottom: SizeConfig.h(6)),
                    child: Text(
                      benefit,
                      style: TextStyle(
                        fontFamily: 'Arbeit',
                        fontWeight: FontWeight.w300,
                        fontSize: SizeConfig.t(11),
                        height: 1.67,
                        letterSpacing: 0,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),

          SizedBox(height: SizeConfig.h(40)),

          // Navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _previousCard(specs.length),
                child: SvgPicture.asset('assets/icons/thin_arrow_left.svg'),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () => _nextCard(specs.length),
                child: SvgPicture.asset('assets/icons/thin_arrow_right.svg'),
              ),

              // // Previous button
              // GestureDetector(
              //   onTap: _previousCard,
              //   child: Container(
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
              //       size: 16,
              //       color: const Color(0xFF2C2C2C),
              //     ),
              //   ),
              // ),
              Spacer(),

              // Page indicator
              Text(
                '${(currentIndex + 1).toString().padLeft(2, '0')} / ${specs.length.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontFamily: 'Basier Square Mono',
                  fontWeight: FontWeight.w400,
                  fontSize: 9.0,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),

          // TODO: connnect with spec url for this section. hide if empty string
          // ================= FOOTER BUTTON =================
          // Center(
          //   child: OutlinedButton(
          //     onPressed: () {},
          //     style: OutlinedButton.styleFrom(
          //       side: const BorderSide(color: Colors.black, width: 1),
          //       shape: const RoundedRectangleBorder(
          //         borderRadius: BorderRadius.zero,
          //       ),
          //       padding: EdgeInsets.symmetric(
          //         horizontal: SizeConfig.w(60),
          //         vertical: SizeConfig.h(22),
          //       ),
          //     ),
          //     child: Text(
          //       "BOOK A SESssSION",
          //       style: TextStyle(
          //         fontFamily: 'Arbeit',
          //         color: Colors.black,
          //         letterSpacing: 1.5,
          //         fontSize: SizeConfig.t(10),
          //         fontWeight: FontWeight.w400,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

}
