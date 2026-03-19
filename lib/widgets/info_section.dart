import 'package:flutter/material.dart';
import 'package:owa_flutter/hero_service.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/widgets/headline.dart';
import 'package:owa_flutter/models/owa_specs.dart';

class InfoSection extends StatefulWidget {
  const InfoSection({super.key});

  @override
  State<InfoSection> createState() => _InfoSectionState();
}

class _InfoSectionState extends State<InfoSection> {
  // Spec state
  OWAMotoTextSpec? _spec;

  @override
  void initState() {
    super.initState();
    _loadSpec();
  }

  Future<void> _loadSpec() async {
    try {
      final spec = await OWAHeroService.fetchMotoTextSpec();
      if (mounted) setState(() => _spec = spec);
    } catch (_) {
      // Silently fall back to hardcoded default below
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use spec motoText if available, otherwise fall back to hardcoded
    final motoText =
        _spec?.data.motoText.isNotEmpty == true
            ? _spec!.data.motoText
            : 'Practice the art of being well.';

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(42)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Spacer
            SizedBox(height: SizeConfig.h(1026.44 - 885)),

            /// Hero heading
            Headline(
              child: Text(
                motoText,
                style: TextStyle(
                  fontFamily: 'Times Now',
                  fontWeight: FontWeight.w400,
                  fontSize: SizeConfig.t(32),
                  height: 1.51,
                  letterSpacing: 0,
                  color: Color(0xFF2C2C2C),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            /// Spacer
            SizedBox(height: SizeConfig.h(1186.44 - (1026.44 + 48))),
          ],
        ),
      ),
    );
  }
}
