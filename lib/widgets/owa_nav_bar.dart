import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:owa_flutter/useful/is_desktop_from_context.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/widgets/owa_animated_nav_item.dart';
import 'package:owa_flutter/widgets/owa_signup_popout.dart';

// Screens
import 'package:owa_flutter/screens/book_session_screen.dart';
import 'package:owa_flutter/screens/services_screen.dart';
import 'package:owa_flutter/screens/science_screen.dart';
import 'package:owa_flutter/screens/therapies_screen.dart';


enum OWANavBarVariant {

  home,

  
  centerLogo,
}

class _OWALogoCropped extends StatelessWidget {
  final Color color;
  final double height;

  const _OWALogoCropped({
    required this.color,
    required this.height,
  });

  // viewBox del SVG original
  static const double _viewW = 1821.33;
  static const double _viewH = 1024.0;

  // ✅ Rectángulo donde realmente vive el logo DENTRO del viewBox
  // (esto “recorta” el whitespace sin tocar el asset)
  static const double _x0 = 484.93;
  static const double _y0 = 456.12;
  static const double _bw = 851.47;
  static const double _bh = 127.715;

  @override
  Widget build(BuildContext context) {
    final scale = height / _bh;
    final width = _bw * scale; // mantiene proporción real del logo

    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: Transform.translate(
          offset: Offset(-_x0 * scale, -_y0 * scale),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: _viewW,
              height: _viewH,
              child: SvgPicture.asset(
                'assets/OWA_Logo.svg', 
                fit: BoxFit.fill,
                alignment: Alignment.topLeft,
                clipBehavior: Clip.none,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OWANavBar extends StatelessWidget {
  final bool useWhiteForeground;
  final OWANavBarVariant variant;


  final List<_NavItemSpec>? rightItemsOverride;

  const OWANavBar({
    super.key,
    this.useWhiteForeground = false,
    this.variant = OWANavBarVariant.centerLogo,
    this.rightItemsOverride,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        useWhiteForeground ? Colors.white : const Color(0xFF1A1A1A);

    if (!isDesktopFromContext(context)) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: SizeConfig.h(66), 
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(42)),
          child: variant == OWANavBarVariant.home
              ? _HomeNavRow(
                  color: foregroundColor,
                  rightItems: rightItemsOverride ?? _defaultHomeItems(context),
                )
              : _CenterLogoNavStack(
                  color: foregroundColor,
                ),
        ),
      ),
    );
  }

  List<_NavItemSpec> _defaultHomeItems(BuildContext context) {
    return [
      _NavItemSpec(
        label: 'Memberships',
        type: NavItemType.circleMono,
        onTap: () {
          // Ajusta a tu routing real:
          // - si es sección en el Home: scrollToMemberships()
          // - si es pantalla: Navigator.push(...)
          // Por ahora lo dejo como placeholder seguro:
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const OWATherapiesPage()),
          );
        },
      ),
      _NavItemSpec(
        label: 'Services',
        type: NavItemType.circleMono,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OWAServicesPage()),
        ),
      ),
      _NavItemSpec(
        label: 'Therapies',
        type: NavItemType.circleMono,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OWATherapiesPage()),
        ),
      ),
      _NavItemSpec(
        label: 'Contact',
        type: NavItemType.circleMono,
        onTap: () {
          // Puede abrir un popout, ir a sección contacto, o navegar:
          // showContactPopout(context);
        },
      ),
    ];
  }
}

/// ✅ HOME: logo izquierda + items derecha (como screenshot)
class _HomeNavRow extends StatelessWidget {
  final Color color;
  final List<_NavItemSpec> rightItems;

  const _HomeNavRow({
    required this.color,
    required this.rightItems,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo izquierda
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
          },
          child: _OWALogoCropped(color: color
          , height: SizeConfig.h(25),
          )
        ),

        const Spacer(),

        // Items derecha
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < rightItems.length; i++) ...[
              _NavBarItem(
                text: rightItems[i].label,
                type: rightItems[i].type,
                color: color,
                onTap: rightItems[i].onTap,
              ),
              if (i != rightItems.length - 1)
                SizedBox(width: SizeConfig.w(18)), // spacing tipo web
            ],
          ],
        ),
      ],
    );
  }
}

/// ✅ CENTER LOGO: tu layout original (logo centrado + izq/der)
class _CenterLogoNavStack extends StatelessWidget {
  final Color color;

  const _CenterLogoNavStack({required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Center Logo
        Align(
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
            },
            child: SizedBox(
              width: SizeConfig.w(167),
              height: SizeConfig.h(25),
              child: SvgPicture.asset(
                'assets/OWA_Logo.svg',
                fit: BoxFit.fitWidth,
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.none,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
          ),
        ),

        // Left + Right groups
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left group
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavBarItem(
                  text: 'BECOME A MEMBER',
                  type: NavItemType.squareMono,
                  color: color,
                  onTap: () => showOwaSignupPopout(context),
                ),
                SizedBox(width: SizeConfig.w(40)),
                _NavBarItem(
                  text: 'BOOK A SESSION',
                  type: NavItemType.squareMono,
                  color: color,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OWABookSessionPage()),
                  ),
                ),
              ],
            ),

            // Right group
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavBarItem(
                  text: 'SERVICES',
                  type: NavItemType.circleMono,
                  color: color,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OWAServicesPage()),
                  ),
                ),
                SizedBox(width: SizeConfig.w(40)),
                _NavBarItem(
                  text: 'SCIENCE',
                  type: NavItemType.circleMono,
                  color: color,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OWASciencePage()),
                  ),
                ),
                SizedBox(width: SizeConfig.w(40)),
                _NavBarItem(
                  text: 'THERAPIES',
                  type: NavItemType.circleMono,
                  color: color,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OWATherapiesPage()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _NavItemSpec {
  final String label;
  final NavItemType type;
  final VoidCallback onTap;

  const _NavItemSpec({
    required this.label,
    required this.type,
    required this.onTap,
  });
}

class _NavBarItem extends StatelessWidget {
  final String text;
  final NavItemType type;
  final Color color;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.text,
    required this.type,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OWAAnimatedNavItem(
      text: text,
      type: type,
      onTap: onTap,
      color: color,
    );
  }
}