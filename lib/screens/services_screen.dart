import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/is_desktop_from_context.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/text_styles.dart';
import 'package:owa_flutter/widgets/footer_section.dart';
import 'package:owa_flutter/widgets/mobile_footer.dart';
import 'package:owa_flutter/widgets/therapies_section.dart';
import 'package:owa_flutter/widgets/owa_nav_bar.dart';

class OWAServicesPage extends StatelessWidget {
  const OWAServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDesktopFromContext(context);
    double s(double v) => SizeConfig.w(v);

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. NAVIGATION BAR
            // Usamos el widget reutilizable. useWhiteForeground: false (letras negras)
            const OWANavBar(useWhiteForeground: false),

            // Espaciado superior (ajustado porque el NavBar ya tiene su propio padding vertical)
            SizedBox(height: isDesktop ? s(100) : SizeConfig.h(70)),

            // Título "Services" pequeño
            if (isDesktop) ...[
              SizedBox(
                width: s(444),
                child: const Center(
                  child: Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
              SizedBox(height: s(60)),
            ],

            // 2. CONTENIDO PRINCIPAL
            if (isDesktop) const OWATherapiesSection() else const _MobileBody(),

            SizedBox(height: isDesktop ? s(80) : SizeConfig.h(48)),

            // 3. FOOTER
            isDesktop
                ? SizedBox(width: s(1440), child: OWAFooter(key: UniqueKey()))
                : OWAMobileFooter(key: UniqueKey()),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MOBILE BODY (Se mantiene local si aún no lo has migrado)
// -----------------------------------------------------------------------------

class _MobileBody extends StatelessWidget {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    // Si tu widget OWATherapiesSection soporta móvil,
    // podrías usarlo aquí también, pero por ahora mantenemos el original
    // para asegurar que no se rompa en pantallas pequeñas.
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Therapies',
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Divider(height: 1, thickness: 1, color: Color(0xFFB9B3AA)),
            ),
            SizedBox(width: 16),
            Text('2.0', style: OWATextStyles.sectionTitleIndex),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "OWA's brings you the latest methods and most powerful practices that balance body and mind.\n\nFrom contrast therapies to advanced technologies, each session invites you to invigorate, reset, restore, and realign.",
          style: OWATextStyles.sectionSubtitle,
        ),
        const SizedBox(height: 22),
        // Nota: Asegúrate de tener assets/follow_us_4.jpg
        ClipRect(
          child: Image.asset('assets/follow_us_4.jpg', fit: BoxFit.cover),
        ),
        const SizedBox(height: 22),
        // Aquí podrías adaptar el acordeón móvil, o dejarlo como estaba
        // si no quieres tocar nada de los widgets originales en móvil.
        const SizedBox(height: 28),
        SizedBox(
          width: 257,
          height: 43,
          child: OutlinedButton(
            onPressed: null,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1A1A1A), width: 1),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: const Text(
              'BOOK A SESSION',
              style: TextStyle(
                fontFamily: 'Instrument Sans',
                fontSize: 10,
                letterSpacing: 2.0,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
