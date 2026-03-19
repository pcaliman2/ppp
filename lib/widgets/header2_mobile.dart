import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:owa_flutter/crud/privacy_notice_screen.dart';

enum Header2MobileNavItemType { squareMono, circleMono }

////Le voy a poner header2_mobile para se consecuente con el otro widget
///sobre todo con el sufijo "2"
class OWAHeader2Mobile extends StatelessWidget {
  const OWAHeader2Mobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        color: const Color(0xFFF6EFE7),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: SizedBox(
          height: 36,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => OWAPrivacyNoticePage()),
                    );
                  },
                  child: _buildLogo(),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => _openMenu(context),
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: Icon(Icons.menu, size: 24, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
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

  void _openMenu(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => const _OWAHeader2MobileFullscreenMenu(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 180),
      ),
    );
  }
}

class _OWAHeader2MobileFullscreenMenu extends StatelessWidget {
  const _OWAHeader2MobileFullscreenMenu();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFE7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MenuTopBar(
                onLogoTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => OWAPrivacyNoticePage()),
                  );
                },
                onCloseTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 56),
              _OWAHeader2MobileMenuTextItem(
                text: 'BECOME A MEMBER',
                type: Header2MobileNavItemType.squareMono,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 30),
              _OWAHeader2MobileMenuTextItem(
                text: 'BOOK A SESSION',
                type: Header2MobileNavItemType.squareMono,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 30),
              _OWAHeader2MobileMenuTextItem(
                text: 'SERVICES',
                type: Header2MobileNavItemType.circleMono,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 30),
              _OWAHeader2MobileMenuTextItem(
                text: 'FAQ',
                type: Header2MobileNavItemType.circleMono,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 30),
              _OWAHeader2MobileMenuTextItem(
                text: 'THERAPIES',
                type: Header2MobileNavItemType.circleMono,
                showArrow: true,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTopBar extends StatelessWidget {
  final VoidCallback onLogoTap;
  final VoidCallback onCloseTap;

  const _MenuTopBar({required this.onLogoTap, required this.onCloseTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: onLogoTap,
            child: Container(
              height: 40,
              alignment: Alignment.centerLeft,
              child: SvgPicture.asset(
                'assets/OWA_Logo.svg',
                height: 200,
                fit: BoxFit.fitWidth,
                colorFilter: const ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: onCloseTap,
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Icon(Icons.close, size: 24, color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OWAHeader2MobileMenuTextItem extends StatefulWidget {
  final String text;
  final Header2MobileNavItemType type;
  final VoidCallback? onTap;
  final bool showArrow;

  const _OWAHeader2MobileMenuTextItem({
    required this.text,
    required this.type,
    this.onTap,
    this.showArrow = false,
  });

  @override
  State<_OWAHeader2MobileMenuTextItem> createState() =>
      _OWAHeader2MobileMenuTextItemState();
}

class _OWAHeader2MobileMenuTextItemState
    extends State<_OWAHeader2MobileMenuTextItem> {
  bool _isPressed = false;

  TextStyle _baseStyle() {
    return TextStyle(
      fontFamily: 'Basier Square Mono',
      fontSize: 16,
      fontWeight: _isPressed ? FontWeight.w500 : FontWeight.w400,
      color: Colors.black.withOpacity(_isPressed ? 0.82 : 0.92),
      letterSpacing: 2.2,
      height: 1.2,
    );
  }

  Widget _trailing() {
    if (!widget.showArrow) return const SizedBox.shrink();

    return const Padding(
      padding: EdgeInsets.only(left: 10),
      child: Icon(Icons.arrow_outward, size: 16, color: Colors.black54),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(child: Text(widget.text, style: _baseStyle())),
          _trailing(),
        ],
      ),
    );
  }
}
