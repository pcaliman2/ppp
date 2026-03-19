import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/is_desktop_from_context.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/widgets/fade_in_widget.dart';
import 'package:owa_flutter/widgets/headline.dart';

class OWAEventsSectionMobile extends StatelessWidget {
  const OWAEventsSectionMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDesktopFromContext(context);
    final titleToContentSpacing =
        isDesktop ? SizeConfig.h(40) : SizeConfig.h(72);

    return Container(
      width: double.infinity,
      color: colors.backgroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(20),
        vertical: SizeConfig.h(60),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Headline(
            child: Text(
              'EVENTS',
              style: TextStyle(
                fontFamily: 'Basier Square Mono',
                fontWeight: FontWeight.w400,
                fontSize: SizeConfig.t(16),
                height: 1.51,
                letterSpacing: SizeConfig.t(16) * 0.12,
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ),

          SizedBox(height: titleToContentSpacing),

          // Events Grid - Single column for mobile
          FadeInWidget(
            child: Column(
              children: [
                _buildEventCard(
                  context: context,
                  imagePath: 'assets/events1.png',
                  title: 'WeELLNESS GATHERING',
                  date: 'March 15, 2026',
                  description: 'Soundhealing. King Lafa. 8:00 pm\n\$600 MXN PP',
                ),
                SizedBox(height: SizeConfig.h(56)),
                _buildEventCard(
                  context: context,
                  imagePath: 'assets/events2.png',
                  title: 'BREATHWORK INTENSIVE',
                  date: 'March 22, 2026',
                  description: 'Soundhealing. King Lafa. 8:00 pm\n\$600 MXN PP',
                ),
                SizedBox(height: SizeConfig.h(56)),
                _buildEventCard(
                  context: context,
                  imagePath: 'assets/events3.png',
                  title: 'SOUND BATH EXPERIENCE',
                  date: 'April 5, 2026',
                  description: 'Soundhealing. King Lafa. 8:00 pm\n\$600 MXN PP',
                ),
                SizedBox(height: SizeConfig.h(56)),
                _buildEventCard(
                  context: context,
                  imagePath: 'assets/events4.png',
                  title: 'CULINARY WELLNESS',
                  date: 'April 12, 2026',
                  description: 'Soundhealing. King Lafa. 8:00 pm\n\$600 MXN PP',
                ),
              ],
            ),
          ),

          SizedBox(height: SizeConfig.h(40)),

          // See All Events Button
          //Center(
          //  child: TextButton(
          //    onPressed: () {
          //      // Handle see all events
          //    },
          //    child: Text(
          //      'SEE ALL EVENTS',
          //      style: TextStyle(
          //        fontFamily: 'Basier Square Mono',
          //        fontWeight: FontWeight.w500,
          //        fontSize: SizeConfig.t(11),
          //        letterSpacing: 0.5,
          //        color: const Color(0xFF2C2C2C),
          //        decoration: TextDecoration.underline,
          //      ),
          //    ),
          //  ),
          //),
        ],
      ),
    );
  }

  Widget _buildEventCard({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String date,
    required String description,
  }) {
    final imageRadius = 10.0;
    final descWidth = 281.29;
    final descHeight = 42.0;
    final precio = '\$600 MXN';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen
        Container(
          height: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(imageRadius),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: SizeConfig.h(16)),

        // Fecha y precio en la misma línea
        Row(
          children: [
            Expanded(
              child: Text(
                date,
                style: TextStyle(
                  fontFamily: 'Basier Square Mono',
                  fontWeight: FontWeight.w400,
                  fontSize: SizeConfig.t(10),
                  height: 1.73,
                  color: const Color(0xFF646464),
                ),
              ),
            ),
            Text(
              precio,
              style: TextStyle(
                fontFamily: 'Basier Square Mono',
                fontWeight: FontWeight.w400,
                fontSize: SizeConfig.t(10),
                height: 1.73,
                color: const Color(0xFF646464),
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.h(10)),

        // Descripción
        Container(
          width: descWidth,
          height: descHeight,
          alignment: Alignment.topLeft,
          child: Text(
            description,
            style: TextStyle(
              fontFamily: 'Arbeit',
              fontWeight: FontWeight.w300,
              fontSize: SizeConfig.t(11),
              height: 1.67,
              color: const Color(0xFF2C2C2C),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: SizeConfig.h(12)),

        // Título
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: SizeConfig.t(12),
            height: 1.45,
            letterSpacing: SizeConfig.t(12) * 0.04,
            color: const Color(0xFF2C2C2C),
          ),
        ),
      ],
    );
  }
}
