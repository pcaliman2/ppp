import 'package:flutter/material.dart';
import 'package:owa_flutter/crud/privacy_notice_screen.dart';
import 'package:owa_flutter/hero_service.dart';
import 'package:owa_flutter/widgets/hero_section_main_text_mobile.dart';
import 'package:owa_flutter/models/owa_hero_spec.dart';

class HeroSectionMobile extends StatefulWidget {
  const HeroSectionMobile({super.key});

  @override
  State<HeroSectionMobile> createState() => _HeroSectionMobileState();
}

class _HeroSectionMobileState extends State<HeroSectionMobile>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _textController;
  late Animation<double> _heroZoomAnimation;
  late Animation<double> _heroOpacityAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  // Spec state
  OWAHeroSpec? _spec;

  @override
  void initState() {
    super.initState();

    // Hero image animation controller
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Hero zoom animation - subtle ken-burns effect
    _heroZoomAnimation = Tween<double>(begin: 1.08, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic),
    );

    // Hero opacity animation
    _heroOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
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
      _heroController.forward();
      Future.delayed(const Duration(milliseconds: 600), () {
        _textController.forward();
      });
    });

    _loadSpec();
  }

  Future<void> _loadSpec() async {
    try {
      final spec = await OWAHeroService.fetchHeroSpec();
      if (mounted) setState(() => _spec = spec);
    } catch (_) {
      // Silently fall back to hardcoded defaults below
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          // Split Background Images
          _buildSplitBackgrounds(),

          // Navigation Header
          _buildNavigationHeader(),

          // Center Hero Text with Animation
          _buildCenterHeroText(),
        ],
      ),
    );
  }

  Widget _buildSplitBackgrounds() {
    // Use spec background image URL if available, otherwise fall back to asset
    final bgImageUrl = _spec?.data.heroBackgroundImage.url ?? '';

    return ClipRect(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _heroZoomAnimation,
          _heroOpacityAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            alignment: Alignment.center,
            scale: _heroZoomAnimation.value,
            child: Opacity(
              opacity: _heroOpacityAnimation.value,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                        bgImageUrl.isNotEmpty
                            ? NetworkImage(bgImageUrl) as ImageProvider
                            : const AssetImage('assets/discover_4.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
          child: Stack(
            children: [
              // Center Logo
              Align(
                alignment: Alignment.center,
                child: AnimatedBuilder(
                  animation: _textFadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textFadeAnimation,
                      child: SlideTransition(
                        position: _textSlideAnimation,
                        child: GestureDetector(
                          onTap:
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => OWAPrivacyNoticePage(),
                                ),
                              ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                ' O',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 4.0,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'W',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 4.0,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'A°',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 4.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterHeroText() {
    return Positioned.fill(
      child: Center(
        child: AnimatedBuilder(
          animation: _textFadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _textFadeAnimation,
              child: SlideTransition(
                position: _textSlideAnimation,
                child: const HeroSectionMainTextMobile(),
              ),
            );
          },
        ),
      ),
    );
  }
}
