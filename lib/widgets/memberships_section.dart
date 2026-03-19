import 'package:flutter/material.dart';
import 'package:owa_flutter/memberships_service.dart';
import 'package:owa_flutter/models/owa_specs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/text_styles.dart';
import 'package:owa_flutter/widgets/build_separator.dart';
import 'package:owa_flutter/widgets/fade_in_widget.dart';
import 'package:owa_flutter/widgets/headline.dart';
import 'package:owa_flutter/widgets/membership_spec.dart';
import 'package:owa_flutter/widgets/membership_tile_image_from_url.dart';

class MembershipsSection extends StatefulWidget {
  const MembershipsSection({super.key});

  @override
  State<MembershipsSection> createState() => _MembershipsSectionState();
}

class _MembershipsSectionState extends State<MembershipsSection> {
  // Estado para saber cuál tarjeta está expandida (null = ninguna)
  Set<int> _selectedIndices = {};

  // Spec state
  OWAMembershipsSectionSpec? _spec;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_error != null) return const SizedBox.shrink();

    final membershipsList = _spec!.data.membershipsList;
    final pageDescription = _spec!.data.pageDescription;
    final bookButtonText = _spec!.data.bookButton.text;
    final bookButtonUrl = _spec!.data.bookButton.url;

    final specs = membershipsList.map(_toMembershipSpec).toList();

    // Benefits come from the spec per-item; commonBenefits kept as fallback
    final List<String> commonBenefits = const [
      '• 2 sauna visits/semana',
      '• 1 hiperbárica/semana',
      '• 30 min masaje mensual.',
    ];

    return Container(
      width: SizeConfig.w(1440),
      // Ajusta minHeight si el contenido desplegado empuja mucho hacia abajo
      constraints: const BoxConstraints(minHeight: 1300),
      color: colors.membershipsBackgroundColor,
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(42)),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3388.81 - 3303),

            // ================= HEADER =================
            SizedBox(
              width: SizeConfig.w(1356),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Headline(
                    child: Text(
                      'Memberships',
                      style: OWATextStyles.sectionTitle,
                    ),
                  ),
                  const Spacer(),
                  Text('3.0', style: OWATextStyles.sectionTitleIndex),
                ],
              ),
            ),

            SizedBox(height: 3431.77 - (3388.81 + 33)),

            buildSeparator(),
            SizedBox(height: 3498.72 - 3431.77),

            SizedBox(
              width: SizeConfig.w(522),
              child: Headline(
                child: Text(
                  pageDescription,
                  style: OWATextStyles.sectionSubtitle,
                ),
              ),
            ),

            SizedBox(height: 3627.62 - (3498.72 + 52)),

            // ================= GRID =================
            FadeInWidget(
              child: Wrap(
                spacing: SizeConfig.w(11),
                runSpacing: SizeConfig.h(60),
                crossAxisAlignment: WrapCrossAlignment.start,
                children:
                    specs
                        .take(3)
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (entry) => MembershipTile(
                            spec: entry.value,
                            commonBenefits: commonBenefits,
                            index: entry.key,
                            selectedIndices: _selectedIndices,
                            slowTextAnim: entry.key < 3, // ✅ Pass the set
                            onSelectionChanged: (index) {
                              setState(() {
                                if (_selectedIndices.contains(index)) {
                                  _selectedIndices.remove(index); // Toggle off
                                } else {
                                  _selectedIndices.add(index); // Toggle on
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
              ),
            ),

            SizedBox(height: SizeConfig.h(80)),

            if (bookButtonUrl.isNotEmpty)
              // ================= FOOTER BUTTON =================
              Center(
                child: OutlinedButton(
                  onPressed: () async {
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
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 1),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.w(60),
                      vertical: SizeConfig.h(22),
                    ),
                  ),
                  child: Text(
                    bookButtonText,
                    style: TextStyle(
                      fontFamily: 'Arbeit',
                      color: Colors.black,
                      letterSpacing: 1.5,
                      fontSize: SizeConfig.t(10),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

            SizedBox(height: SizeConfig.h(60)),
          ],
        ),
      ),
    );
  }
}
