import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful_widgets/precise_animated_nav_item.dart';
import 'package:owa_flutter/widgets/footer_section.dart';
import 'package:owa_flutter/useful/is_desktop_from_context.dart';
import 'package:owa_flutter/widgets/mobile_footer.dart';
import 'package:owa_flutter/useful/size_config.dart';

class OWAPrivacyNoticePage extends StatefulWidget {
  const OWAPrivacyNoticePage({super.key});

  @override
  State<OWAPrivacyNoticePage> createState() => _OWAPrivacyNoticePageState();
}

class _OWAPrivacyNoticePageState extends State<OWAPrivacyNoticePage>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Text fade animation
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Text slide animation
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _textController.forward();
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: Stack(
        children: [
          /// Scrollable Content
          SingleChildScrollView(
            child: Column(
              children: [
                /// Add padding to account for the fixed header
                SizedBox(height: 100), // Adjust based on your header height
                /// Content
                _buildContent(),

                /// Footer
                isDesktop ? const OWAFooter() : const OWAMobileFooter(),
              ],
            ),
          ),

          // Fixed Navigation Header on top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildNavigationHeader(),
          ),
        ],
      ),
    );
  }

  AnimatedBuilder _buildContent() {
    return AnimatedBuilder(
      animation: _textFadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textFadeAnimation,
          child: SlideTransition(
            position: _textSlideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),

                // Privacy Notice Title
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.w(
                      isDesktopFromContext(context) ? 297 : 100,
                    ),
                  ),
                  child: const Text(
                    'PRIVACY NOTICE',
                    style: TextStyle(
                      fontFamily: 'Basier Square Mono',
                      fontWeight: FontWeight.w400,
                      fontSize: 19,
                      height: 1.51,
                      letterSpacing: 0.12 * 19, // 12% letter spacing
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Privacy Notice Content
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.w(
                      isDesktopFromContext(context) ? 297 : 100,
                    ),
                  ),
                  child: _buildPrivacyContent(),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationHeader() {
    return Container(
      color: colors.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
      child: SafeArea(
        child: Stack(
          children: [
            // Center Logo - positioned absolutely in the center
            Align(
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: _textFadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textFadeAnimation,
                    child: SlideTransition(
                      position: _textSlideAnimation,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            ' O',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 4.0,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'W',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 4.0,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'A°',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 4.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isDesktopFromContext(context))
              // Left and Right Navigation Items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Navigation Items
                  AnimatedBuilder(
                    animation: _textFadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textFadeAnimation,
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: Row(
                            children: [
                              _buildNavItem('BECOME A MEMBER'),
                              const SizedBox(width: 40),
                              _buildNavItem('BOOK A SESSION'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Right Navigation Items
                  AnimatedBuilder(
                    animation: _textFadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textFadeAnimation,
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: Row(
                            children: [
                              _buildNavItem('SERVICES'),
                              const SizedBox(width: 40),
                              _buildNavItem('SCIENCE'),
                              const SizedBox(width: 40),
                              _buildNavItem('THERAPIES'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String text) {
    return PreciseAnimatedNavItem(
      text: text,
      textColor: Colors.black,
      useInvertedText: true,
    );
  }

  Widget _buildPrivacyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentParagraph(
          'Through these transformative projects we explore new horizons, experience a deeper connection to the world and ourselves, and pave the way for a more aligned and connected future.',
        ),

        const SizedBox(height: 30),

        _buildContentParagraph(
          'For the purposes indicated in this Privacy Notice, it is informed that your identification personal data is collected and processed:',
        ),

        const SizedBox(height: 20),

        _buildContentParagraph('- When you provide it to us directly and/or'),
        _buildContentParagraph(
          '- Through interactions and communications with our website.',
        ),

        const SizedBox(height: 30),

        _buildContentParagraph(
          'For the purposes of this Privacy Notice, the following definitions apply:',
        ),
        _buildContentParagraph(
          'Personal and/or identification data: Any information relating to an identified or identifiable natural person. The personal data we will collect from you includes: name, phone number, email address, location, among others.',
        ),

        const SizedBox(height: 30),

        _buildContentParagraph("""
Additionally, "OWA" collects and stores information through access to its website. This information relates to the visitor\'s IP address/domain name, behavior, and time spent on the website, tools used, browser type, and operating system, among others. This information is obtained and stored to measure site activity and identify browsing trends not attributable to a specific individual. The aforementioned information is collected through "cookies," as well as other technological means and mechanisms, such as pixel tags, web bugs, links in emails, web beacons (internet tags), pixel tags, and clear GIFs'), among others. Most browsers allow you to delete, block, or be warned before storing cookies. We suggest you consult your browser\'s instructions for managing "cookies."
"""),

        const SizedBox(height: 50),

        // Legacy Section
        const Text(
          'LEGACY',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w400,
            fontSize: 19,
            height: 1.51,
            letterSpacing: 0.12 * 19, // 12% letter spacing
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 40),

        _buildContentParagraph(
          'Through these transformative projects we explore new horizons, experience a deeper connection to the world and ourselves, and pave the way for a more aligned and connected future.',
        ),

        const SizedBox(height: 30),

        _buildContentParagraph(
          'For the purposes indicated in this Privacy Notice, it is informed that your identification personal data is collected and processed:',
        ),

        const SizedBox(height: 20),

        _buildContentParagraph('- When you provide it to us directly and/or'),
        _buildContentParagraph(
          '- Through interactions and communications with our website.',
        ),
        _buildContentParagraph(
          'For the purposes of this Privacy Notice, the following definitions apply:',
        ),
        _buildContentParagraph(
          'Personal and/or identification data: Any information relating to an identified or identifiable natural person. The personal data we will collect from you includes: name, phone number, email address, location, among others.',
        ),

        const SizedBox(height: 30),

        _buildContentParagraph("""
Additionally, "OWA" collects and stores information through access to its website. This information relates to the visitor\'s IP address/domain name, behavior, and time spent on the website, tools used, browser type, and operating system, among others. This information is obtained and stored to measure site activity and identify browsing trends not attributable to a specific individual. The aforementioned information is collected through "cookies," as well as other technological means and mechanisms, such as pixel tags, web bugs, links in emails, web beacons (internet tags), pixel tags, and clear GIFs'), among others. Most browsers allow you to delete, block, or be warned before storing cookies. We suggest you consult your browser\'s instructions for managing "cookies."
"""),

        const SizedBox(height: 50),

        // Repeated content sections as shown in the design
        _buildRepeatedContentSections(),
      ],
    );
  }

  Widget _buildContentParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Arbeit',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.5, // 150% line height
          letterSpacing: 0, // 0% letter spacing
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildRepeatedContentSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Additional repeated sections as shown in the design
        _buildContentParagraph(
          'Through these transformative projects we explore new horizons, experience a deeper connection to the world and ourselves, and pave the way for a more aligned and connected future.',
        ),

        const SizedBox(height: 30),

        _buildContentParagraph(
          'For the purposes indicated in this Privacy Notice, it is informed that your identification personal data is collected and processed:',
        ),

        const SizedBox(height: 20),

        _buildContentParagraph('- When you provide it to us directly and/or'),
        _buildContentParagraph(
          '- Through interactions and communications with our website.',
        ),
        _buildContentParagraph(
          'For the purposes of this Privacy Notice, the following definitions apply:',
        ),
        _buildContentParagraph(
          'Personal and/or identification data: Any information relating to an identified or identifiable natural person. The personal data we will collect from you includes: name, phone number, email address, location, among others.',
        ),

        const SizedBox(height: 30),

        _buildContentParagraph("""
Additionally, "OWA" collects and stores information through access to its website. This information relates to the visitor\'s IP address/domain name, behavior, and time spent on the website, tools used, browser type, and operating system, among others. This information is obtained and stored to measure site activity and identify browsing trends not attributable to a specific individual. The aforementioned information is collected through "cookies," as well as other technological means and mechanisms, such as pixel tags, web bugs, links in emails, web beacons (internet tags), pixel tags, and clear GIFs'), among others. Most browsers allow you to delete, block, or be warned before storing cookies. We suggest you consult your browser\'s instructions for managing "cookies."
"""),

        const SizedBox(height: 50),

        // Final repeated section
        _buildContentParagraph(
          'Through these transformative projects we explore new horizons, experience a deeper connection to the world and ourselves, and pave the way for a more aligned and connected future.',
        ),

        const SizedBox(height: 30),

        _buildContentParagraph(
          'For the purposes indicated in this Privacy Notice, it is informed that your identification personal data is collected and processed:',
        ),

        const SizedBox(height: 20),

        _buildContentParagraph('- When you provide it to us directly and/or'),
        _buildContentParagraph(
          '- Through interactions and communications with our website.',
        ),
        _buildContentParagraph(
          'For the purposes of this Privacy Notice, the following definitions apply:',
        ),
        _buildContentParagraph(
          'Personal and/or identification data: Any information relating to an identified or identifiable natural person. The personal data we will collect from you includes: name, phone number, email address, location, among others.',
        ),

        const SizedBox(height: 30),

        _buildContentParagraph("""
Additionally, "OWA" collects and stores information through access to its website. This information relates to the visitor\'s IP address/domain name, behavior, and time spent on the website, tools used, browser type, and operating system, among others. This information is obtained and stored to measure site activity and identify browsing trends not attributable to a specific individual. The aforementioned information is collected through "cookies," as well as other technological means and mechanisms, such as pixel tags, web bugs, links in emails, web beacons (internet tags), pixel tags, and clear GIFs'), among others. Most browsers allow you to delete, block, or be warned before storing cookies. We suggest you consult your browser\'s instructions for managing "cookies."
"""),
      ],
    );
  }
}
