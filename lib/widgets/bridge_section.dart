import 'package:flutter/material.dart';
import 'dart:async';

import 'package:owa_flutter/useful/is_desktop_from_context.dart';
import 'package:owa_flutter/widgets/animated_hero_text.dart';
import 'package:owa_flutter/widgets/animated_hero_text_mobile.dart';

class BridgeSection extends StatefulWidget {
  const BridgeSection({super.key});

  @override
  State<BridgeSection> createState() => _BridgeSectionState();
}

class _BridgeSectionState extends State<BridgeSection>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _textController;
  late Animation<double> _heroZoomAnimation;
  late Animation<double> _heroOpacityAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

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

    /// Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _heroController.forward();
      Future.delayed(const Duration(milliseconds: 600), () {
        _textController.forward();
      });
    });
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
      height: 530,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          /// Split Background Images
          _buildSplitBackgrounds(),

          /// Center Hero Text with Animation
          _buildCenterHeroText(),
        ],
      ),
    );
  }

  Widget _buildSplitBackgrounds() {
    return ClipRect(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _heroZoomAnimation,
          _heroOpacityAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _heroZoomAnimation.value,
            child: Opacity(
              opacity: _heroOpacityAnimation.value,
              child: Container(
                height: 530,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/bridge.jpg',
                    ), // Your left background image
                    fit: BoxFit.cover,
                  ),
                ),
                // Dark overlay for better text contrast
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.4),
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
                child:
                    isDesktopFromContext(context)
                        ? const AnimatedHeroText()
                        : const AnimatedHeroTextMobile(),
              ),
            );
          },
        ),
      ),
    );
  }
}
