import 'package:owa_flutter/useful_widgets/fade_in_widget.dart';
import 'package:owa_flutter/useful_widgets/headline.dart';
import 'package:flutter/material.dart';

class StatusWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final void Function()? onTapAC2;

  const StatusWidget({
    super.key,
    this.title = 'Status',
    this.subtitle = 'TBD',
    this.onTapAC2,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleContainsAC2 = subtitle.contains('AC²');

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title.isEmpty ? " " : title,
            style: const TextStyle(
              fontFamily: 'Uncut Sans',
              fontWeight: FontWeight.w400,
              fontSize: 15,
              height: 1.39, // 139% line height
              letterSpacing: 0,
              color: Color(0xFF9E9E9E), // Gray color from the image
            ),
          ),
          const SizedBox(height: 12),

          // Divider line
          HorizontalFadeInWidget(
            child: Container(
              width: 270,
              height: 1,
              color:
                  title.isEmpty && subtitle.isEmpty
                      ? Colors.transparent
                      : const Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          if (subtitleContainsAC2) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subtitle.isEmpty ? " " : subtitle,
                  style: const TextStyle(
                    fontFamily: 'Uncut Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    height: 1.39, // 139% line height
                    letterSpacing: 0,
                    color: Color(0xFF000000), // Black color
                  ),
                ),
                Headline(
                  child: Text(
                    "View More",
                    style: const TextStyle(
                      fontFamily: 'Uncut Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                      height: 1.39, // 139% line height
                      letterSpacing: 0,
                      color: Color(0xFF000000), // Black color
                    ),
                  ),
                ),
              ],
            ),
          ] else
            Text(
              subtitle.isEmpty ? " " : subtitle,
              style: const TextStyle(
                fontFamily: 'Uncut Sans',
                fontWeight: FontWeight.w400,
                fontSize: 17,
                height: 1.39, // 139% line height
                letterSpacing: 0,
                color: Color(0xFF000000), // Black color
              ),
            ),
        ],
      ),
    );

    return subtitleContainsAC2 && onTapAC2 != null
        ? GestureDetector(onTap: onTapAC2, child: child)
        : child;
  }
}
