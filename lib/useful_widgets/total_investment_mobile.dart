import 'package:owa_flutter/useful/parse_subtitle.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful_widgets/fade_in_widget.dart';
import 'package:owa_flutter/useful_widgets/animated_counter.dart';
import 'package:flutter/material.dart';

class TotalInvestmentMobile extends StatelessWidget {
  final String title;
  final String subtitle;

  const TotalInvestmentMobile({
    super.key,
    this.title = 'Total Investment',
    this.subtitle = '\$TBD',
  });

  @override
  Widget build(BuildContext context) {
    final parsed = parseSubtitle(subtitle);
    final numericPart = parsed['numeric']!;
    final unitPart = parsed['unit']!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Uncut Sans',
              fontWeight: FontWeight.w400,
              fontSize: 23,
              height: 0.95,
              letterSpacing: 0,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 1905.88 - (1852.62 + 22)),

          // Divider line
          HorizontalFadeInWidget(
            child: Container(
              width: SizeConfig.w(494),
              height: 1,
              color: const Color(0xFF000000),
            ),
          ),
          const SizedBox(height: (1935.14 - 1905.88)),

          // Subtitle with AnimatedCounter
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Animated numeric part - First Figma style
              AnimatedCounter(
                targetValue: numericPart,
                style: const TextStyle(
                  fontFamily: 'TWK Everett',
                  fontWeight: FontWeight.w400, // Regular
                  fontSize: 65,
                  height: 1.2, // 120%
                  letterSpacing: 0,
                  color: Colors.black,
                ),
                duration: Duration(milliseconds: 5000),
                visibilityKey: Key('counter_revenue'),
              ),
              // Static unit part - Second Figma style
              if (unitPart.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  unitPart,
                  style: const TextStyle(
                    fontFamily: 'TWK Everett',
                    fontWeight: FontWeight.w500, // Medium
                    fontSize: 45,
                    height: 1.2, // 120%
                    letterSpacing: 0,
                    color: Colors.black,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
