// header2.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:owa_flutter/widgets/owa_animated_nav_item.dart'; // Se usa para NavItemType
import 'package:owa_flutter/crud/privacy_notice_screen.dart';

enum NavItemType2 { squareMono, circleMono }

/// Esta es mi version del Header hasta que randy termine la definitiva
class OWAAnimatedNavItem2 extends StatefulWidget {
  final String text;
  final NavItemType2 type;
  final Color color;

  const OWAAnimatedNavItem2({
    Key? key,
    required this.text,
    required this.type,
    this.color = const Color.fromARGB(255, 252, 33, 33),
  }) : super(key: key);

  @override
  State<OWAAnimatedNavItem2> createState() => _OWAAnimatedNavItem2State();
}

class _OWAAnimatedNavItem2State extends State<OWAAnimatedNavItem2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() {
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _onExit() {
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  TextStyle _getTextStyle() {
    return const TextStyle(
      fontFamily: 'Instrument Sans',
      color: Colors.black,
      fontSize: 11, // 11px
      fontWeight: FontWeight.w400,
      height: 1.5, // 150%
      letterSpacing: 0.0,
    );
  }

  TextStyle _getHoveredTextStyle() {
    final baseStyle = _getTextStyle();
    return baseStyle.copyWith(fontWeight: FontWeight.w500);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: _isHovered ? _getHoveredTextStyle() : _getTextStyle(),
              child: Text(widget.text),
            ),
            const SizedBox(height: 6),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.centerLeft,
                  transform:
                      Matrix4.identity()..scale(_scaleAnimation.value, 1.0),
                  child: Container(
                    width: _getTextWidth(),
                    height: 1.0,
                    decoration: const BoxDecoration(color: Colors.black),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  double _getTextWidth() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: _isHovered ? _getHoveredTextStyle() : _getTextStyle(),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }
}

/// Aqui creo la clase del Headder y la voy a llamar header2
/// Porque no se si hay otra y nombre tenga conflicto
/// por eso puse el 2
class OWAHeader2 extends StatelessWidget {
  const OWAHeader2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        color: const Color(
          0xFFF6EFE7,
        ), // Fondo crema igual que signup_section.dart
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OWAPrivacyNoticePage(),
                      ),
                    ),
                child: _buildLogo(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildNavItem('BECOME A MEMBER', NavItemType.squareMono),
                    const SizedBox(width: 40),
                    _buildNavItem('BOOK A SESSION', NavItemType.squareMono),
                  ],
                ),
                Row(
                  children: [
                    _buildNavItem('SERVICES', NavItemType.circleMono),
                    const SizedBox(width: 40),
                    _buildNavItem('FAQ', NavItemType.circleMono),
                    const SizedBox(width: 40),
                    _buildNavItem('THERAPIES', NavItemType.circleMono),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 40,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/OWA_Logo.svg',
        height: 200,
        fit: BoxFit.fitWidth,
        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildNavItem(String text, NavItemType type) {
    return OWAAnimatedNavItem2(
      text: text,
      type:
          type == NavItemType.squareMono
              ? NavItemType2.squareMono
              : NavItemType2.circleMono,
    );
  }
}
