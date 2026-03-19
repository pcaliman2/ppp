// widgets/owa_navbar_desktop.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful_widgets/precise_animated_nav_item.dart';
import 'package:owa_flutter/widgets/owa_logo.dart';

class OWANavbarDesktop extends StatelessWidget {
  const OWANavbarDesktop({
    super.key,
    this.onNavTap,
    this.onLogoTap,
    this.onCartTap,
    this.cartItemCount = 0,
  });

  final void Function(String label)? onNavTap;
  final VoidCallback? onLogoTap;
  final VoidCallback? onCartTap;
  final int cartItemCount;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                behavior: HitTestBehavior.opaque,
                onTap: onLogoTap,
                child: OWALogo(color: Colors.black),
              ),

              const Spacer(),

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
                  //   _buildCartButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String text) {
    return GestureDetector(
      onTap: () => onNavTap?.call(text),
      child: PreciseAnimatedNavItem(text: text, useInvertedText: true),
    );
  }

  Widget _buildCartButton() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onCartTap,
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
                color: Colors.black.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.35),
                  width: 0.8,
                ),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: Colors.black.withValues(alpha: 0.9),
                size: 20,
              ),
            ),
            if (cartItemCount > 0)
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
                    color: Colors.black,
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
                    '$cartItemCount',
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
}
