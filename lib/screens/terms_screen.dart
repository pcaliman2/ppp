import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:owa_flutter/useful/size_config.dart'; // [1] Importación de SizeConfig
import 'package:owa_flutter/useful_widgets/precise_animated_nav_item.dart';
import 'package:owa_flutter/widgets/footer_section.dart';

import 'package:owa_flutter/screens/member_screen.dart';
import 'package:owa_flutter/screens/book_session_screen.dart';
import 'package:owa_flutter/screens/services_screen.dart';
import 'package:owa_flutter/screens/science_screen.dart';
import 'package:owa_flutter/screens/therapies_screen.dart';

class OWATermsPage extends StatelessWidget {
  const OWATermsPage({super.key});

  static const _bg = Color(0xFFEDE8E1);
  static const _text = Color(0xFF1A1A1A);

  void _goTo(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    // [2] Inicialización de SizeConfig para recalcular con el contexto correcto
    SizeConfig.init(context, figmaWidth: 1440, figmaHeight: 1024);

    const termsText =
        'Through these transformative projects we explore new horizons, experience a deeper connection to the world and ourselves, and pave the way for a more aligned and connected future.\n\n'
        'For the purposes indicated in this Privacy Notice, it is informed that your identification personal data is collected and processed:\n\n'
        '- When you provide it to us directly and/or\n'
        '- Through interactions and communications with our website.\n\n'
        'For the purposes of this Privacy Notice, the following definitions apply:\n'
        'Personal and/or identification data: Any information relating to an identified or identifiable natural person. '
        'The personal data we will collect from you includes: name, phone number, email address, location, among others.\n\n'
        'Additionally, “OWA” collects and stores information through access to its website. This information relates to the visitor’s IP address/domain name, '
        'behavior, and time spent on the website, tools used, browser type, and operating system, among others. This information is obtained and stored to '
        'measure site activity and identify browsing trends not attributable to a specific individual. The aforementioned information is collected through “cookies”, '
        'as well as other technological means and mechanisms, such as pixel tags, web bugs, links in emails, web beacons (Internet tags, pixel tags, and clear GIFs), among others. '
        'Most browsers allow you to delete, block, or be warned before storing cookies. We suggest you consult your browser’s instructions for managing “cookies.”';

    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        // [3] SizedBox para ocupar todo el ancho y estirar la columna
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- NAVBAR ---
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 25,
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: SizedBox(
                            height: 40,
                            child: SvgPicture.asset(
                              'assets/OWA_Logo.svg',
                              fit: BoxFit.fitWidth,
                              colorFilter: const ColorFilter.mode(
                                _text,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap:
                                    () => _goTo(context, const OWAMemberPage()),
                                child: PreciseAnimatedNavItem(
                                  text: 'BECOME A MEMBER',
                                  textColor: _text,
                                  useInvertedText: true,
                                ),
                              ),
                              const SizedBox(width: 40),
                              GestureDetector(
                                onTap:
                                    () => _goTo(
                                      context,
                                      const OWABookSessionPage(),
                                    ),
                                child: PreciseAnimatedNavItem(
                                  text: 'BOOK A SESSION',

                                  textColor: _text,
                                  useInvertedText: true,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap:
                                    () =>
                                        _goTo(context, const OWAServicesPage()),
                                child: PreciseAnimatedNavItem(
                                  text: 'SERVICES',
                                  textColor: _text,
                                  useInvertedText: true,
                                ),
                              ),
                              const SizedBox(width: 40),
                              GestureDetector(
                                onTap:
                                    () =>
                                        _goTo(context, const OWASciencePage()),
                                child: PreciseAnimatedNavItem(
                                  text: 'SCIENCE',
                                  textColor: _text,
                                  useInvertedText: true,
                                ),
                              ),
                              const SizedBox(width: 40),
                              GestureDetector(
                                onTap:
                                    () => _goTo(
                                      context,
                                      const OWATherapiesPage(),
                                    ),
                                child: PreciseAnimatedNavItem(
                                  text: 'THERAPIES',
                                  textColor: _text,
                                  useInvertedText: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // --- CONTENT BLOCK ---
              LayoutBuilder(
                builder: (context, c) {
                  final frameW = c.maxWidth >= 1440 ? 1440.0 : c.maxWidth;
                  final s = frameW / 1440.0;

                  return Center(
                    child: SizedBox(
                      width: frameW,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 60 * s),
                          Padding(
                            padding: EdgeInsets.only(left: 156 * s),
                            child: SizedBox(
                              width: 216 * s,
                              child: Text(
                                'PRIVACY NOTICE',
                                style: TextStyle(
                                  fontFamily: 'Basier Square Mono',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 19 * s,
                                  height: 1.51,
                                  letterSpacing: 2.28 * s,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 46 * s),
                          Padding(
                            padding: EdgeInsets.only(left: 273 * s),
                            child: SizedBox(
                              width: 897 * s,
                              child: SelectableText(
                                termsText,
                                style: TextStyle(
                                  fontFamily: 'Arbeit',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14 * s,
                                  height: 1.5,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 120 * s),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // --- FOOTER ---
              const OWAFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
