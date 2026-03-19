import 'package:flutter/material.dart';
import 'dart:async';

import 'package:owa_flutter/crud/privacy_notice_screen.dart';
import 'package:owa_flutter/hero_service.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/text_styles.dart';
import 'package:owa_flutter/useful_widgets/precise_animated_nav_item.dart';
import 'package:owa_flutter/widgets/action_button.dart';
import 'package:owa_flutter/widgets/owa_logo.dart';
// 1) Import
import 'package:owa_flutter/widgets/owa_signup_popout.dart';
import 'package:owa_flutter/models/owa_hero_spec.dart';

// 2) Flag global (para asegurar que solo salga una vez por sesión de la app)
bool _owaSignupPopoutShownThisRun = false;
const Duration _signupPopoutDelay = Duration(seconds: 5);

//  1. Modificación de la firma para aceptar callback
class HeroSection extends StatefulWidget {
  const HeroSection({
    super.key,
    this.onNavTap,
    this.onCartTap,
    this.cartItemCount = 0,
  });

  final void Function(String label)? onNavTap;
  final VoidCallback? onCartTap;
  final int cartItemCount;

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _textController;
  late Animation<double> _heroZoomAnimation;
  late Animation<double> _heroOpacityAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  // 3) Timer field
  Timer? _popoutTimer;

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

      // 4) Llamada en postFrameCallback
      _maybeShowSignupPopoutOnce();
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
    // 6) Cancelar timer
    _popoutTimer?.cancel();

    _heroController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // 5) Método lógico para mostrar el popout
  void _maybeShowSignupPopoutOnce() {
    if (_owaSignupPopoutShownThisRun) return;
    _owaSignupPopoutShownThisRun = true;

    _popoutTimer?.cancel();
    _popoutTimer = Timer(_signupPopoutDelay, () {
      if (!mounted) return;

      showOwaSignupPopout(
        context,
        image: const AssetImage('assets/membership_1.jpg'),
      );
    });
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

          // Bottom Right Logo Icon
          // _buildBottomRightIcon(),
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
      child: ClipRect(
        child: Container(
          padding: EdgeInsets.only(
            left: SizeConfig.w(42),
            right: SizeConfig.w(42),
            top: SizeConfig.w(32),
            bottom: SizeConfig.w(16 * 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo LEFT
              GestureDetector(
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OWAPrivacyNoticePage(),
                      ),
                    ),
                child: _buildLogo(),
              ),

              Spacer(),

              // Nav items RIGHT
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: SizeConfig.w(70),
                    child: _buildNavItem('Memberships'),
                  ),
                  const SizedBox(width: 34),
                  SizedBox(
                    width: SizeConfig.w(50),
                    child: _buildNavItem('Services'),
                  ),
                  const SizedBox(width: 34),
                  SizedBox(
                    width: SizeConfig.w(55),
                    child: _buildNavItem('Therapies'),
                  ),
                  const SizedBox(width: 34),
                  SizedBox(
                    width: SizeConfig.w(50),
                    child: _buildNavItem('Contact'),
                  ),
                  const SizedBox(width: 34),
                  SizedBox(
                    width: SizeConfig.w(50),
                    child: _buildNavItem('FAQ'),
                  ),
                  const SizedBox(width: 34),
                  // _buildCartButton(),
                  //_buildCartButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return OWALogo();
  }

  // ✅ 2. Hacemos el NavItem clickeable
  Widget _buildNavItem(String text) {
    return GestureDetector(
      // behavior: HitTestBehavior.translucent,
      onTap: () => widget.onNavTap?.call(text),
      child: PreciseAnimatedNavItem(text: text, useInvertedText: true),
    );
  }

  Widget _buildCartButton() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onCartTap,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 0.8,
                ),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white.withValues(alpha: 0.9),
                size: 20,
              ),
            ),
            // Badge
            if (widget.cartItemCount > 0)
              Positioned(
                right: -6,
                top: -6,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOutCubic,
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '${widget.cartItemCount}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF222222),
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterHeroText() {
    // Use spec heroText if available, otherwise fall back to hardcoded copy
    final copy =
        _spec?.data.heroText.isNotEmpty == true
            ? _spec!.data.heroText
            : "OWA° is Mexico City's first wellness club,\n"
                "bringing together the essential pillars of human\n"
                "wellbeing in one place.";

    // Use spec button text if available, otherwise fall back to hardcoded
    final ctaText =
        _spec?.data.heroButton.text.isNotEmpty == true
            ? _spec!.data.heroButton.text
            : 'BOOK YOUR FIRST VISIT';

    return Positioned.fill(
      child: Center(
        child: AnimatedBuilder(
          animation: _textFadeAnimation,
          builder: (context, child) {
            final w = MediaQuery.of(context).size.width;

            final maxCopyWidth = w >= 1200 ? 640.0 : w * 0.75;
            final buttonWidth =
                w >= 1200 ? 420.0 : (w * 0.70).clamp(260.0, 420.0);

            return FadeTransition(
              opacity: _textFadeAnimation,
              child: SlideTransition(
                position: _textSlideAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxCopyWidth),
                      child: Text(
                        copy,
                        textAlign: TextAlign.center,
                        style: OWATextStyles.heroMainText,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // CTA button
                    ActionButton(
                      text: ctaText,
                      onTap: () {
                        widget.onNavTap?.call('Therapies');
                      },

                      width: buttonWidth,
                      height: 44,
                      margin: EdgeInsets.zero,

                      baseColor: Colors.black.withValues(alpha: 0.10),
                      hoverColor: Colors.white.withValues(alpha: 0.08),
                      borderColor: Colors.white.withValues(alpha: 0.35),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
