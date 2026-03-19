import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/text_styles.dart';
import 'package:owa_flutter/useful_widgets/headline.dart';
import 'package:owa_flutter/widgets/build_separator.dart';
import 'package:owa_flutter/useful_widgets/animated_menu_icon_stack.dart';
import 'package:owa_flutter/models/owa_specs.dart';
import 'package:owa_flutter/widgets/owa_therapies_service.dart';
import 'package:url_launcher/url_launcher.dart';

class OWATherapiesSection extends StatefulWidget {
  const OWATherapiesSection({super.key});

  @override
  State<OWATherapiesSection> createState() => _OWATherapiesSectionState();
}

class _OWATherapiesSectionState extends State<OWATherapiesSection>
    with TickerProviderStateMixin {
  // Estado de la expansión
  String? _expandedTherapy;

  // Estado de la imagen seleccionada (inicia en primer therapy del spec)
  String _selectedTherapy = '';

  // Spec state
  OWATherapiesSectionSpec? _spec;
  bool _isLoading = true;
  String? _error;
  bool _isPrecacheScheduled = false;

  // ==========================================
  // ===== HELPER DE ESCALADO UNIFICADO =====
  // ==========================================
  double s(double v) => SizeConfig.w(v);

  // Layout widths base (Page)
  double get _pageW => s(1440);
  double get _padX => s(42);

  // ==========================================
  // ===== 1) CONSTANTES FIGMA (Header) =====
  // ==========================================
  double get _figTitleW => s(444);
  double get _figTitleH => s(30);

  double get _figDividerW => s(1355.5625);
  double get _figDividerH => s(1);

  double get _figDescW => s(521.93);
  double get _figDescH => s(52);

  // Gaps
  double get _gapTitleToDivider => s(12.95);
  double get _gapDividerToDesc => s(44.43); // 2122.38 - 2077.95 = 44.43 OK!!!

  // ==================================================
  // ===== 2) CONSTANTES FIGMA (List + Image) =====
  // ==================================================

  // Ancho del bloque izquierdo TOTAL
  double get _leftColW => s(507.50439453125);

  // Ancho de la LÍNEA y del ROW clickeable
  double get _itemLineW => s(507.504);

  // Icono + / -
  double get _plusBox => SizeConfig.w(9.92) * 1.6;

  // Contenido expandido
  double get _accDescW => s(429.49);

  // Columnas beneficios
  double get _benefitsLeftW => s(216);
  double get _benefitsRightW => s(120);
  double get _benefitsGap => s(60.91);

  // Espaciados verticales generales
  double get _gapDescToList => s(2279.35 - (2122.38 + 52)); // s(156.97);

  // Imagen derecha
  double get _imageW => 511.46;
  double get _imageH => 520.0;

  // Radio escalable
  double get _imageRadius => 10;

  // Offset vertical imagen
  double get _imageTopOffset => s(14.44);

  // --- FIXES FIGMA (Alineación exacta) ---

  // Espaciado final para alinear visualmente la lista con el fondo de la imagen
  double get _listBottomPadToMatchImage => s(44.736);

  // Ajustes Header Item (Slot fijo + Nudge + Box Text)
  double get _itemHeaderH => s(35.0);
  double get _itemStroke => s(0.75);
  double get _itemNudgeY => s(-1.2);

  // ==========================
  // ===== LIFECYCLE =====
  // ==========================

  @override
  void initState() {
    super.initState();
    _loadSpec();
  }

  Future<void> _loadSpec() async {
    try {
      final spec = await OWATherapiesService.fetchSpec();
      setState(() {
        _spec = spec;
        // Inicia seleccionando el primer therapy del spec
        if (spec.data.therapiesList.isNotEmpty) {
          _selectedTherapy = spec.data.therapiesList.first.therapyName;
        }
        _isLoading = false;
      });

      if (!_isPrecacheScheduled) {
        _isPrecacheScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _precacheTherapyImages(spec.data.therapiesList);
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _precacheTherapyImages(List<OWATherapyItem> therapies) async {
    if (!mounted) return;
    for (final therapy in therapies) {
      final imageUrl = therapy.therapyImage.url.trim();
      if (imageUrl.isEmpty) continue;
      try {
        await precacheImage(NetworkImage(imageUrl), context);
      } catch (_) {
        // Ignore precache failures and let normal network loading handle it.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_error != null) return const SizedBox.shrink();

    final therapiesList = _spec!.data.therapiesList;
    final bookButtonText = _spec!.data.bookButton.text;
    final bookButtonUrl = _spec!.data.bookButton.url;
    final pageDescription = _spec!.data.pageDescription;

    // Map therapyName -> OWATherapyItem for quick lookup
    final Map<String, OWATherapyItem> therapyMap = {
      for (final t in therapiesList) t.therapyName: t,
    };

    return Container(
      width: _pageW,
      color: colors.backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: _padX),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(height: s(28)),

          // ==============================================
          // ===== 1) HEADER SECTION ======================
          // ==============================================
          SizedBox(
            width: _figDividerW,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _figTitleW,
                  height: _figTitleH,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Headline(
                      child: Text(
                        'Therapies',
                        style: OWATextStyles.sectionTitle,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Headline(
                  child: Text('2.0', style: OWATextStyles.sectionTitleIndex),
                ),
              ],
            ),
          ),

          SizedBox(height: _gapTitleToDivider),

          buildSeparator(),

          SizedBox(height: _gapDividerToDesc),

          SizedBox(
            width: _figDescW,
            height: _figDescH,
            child: Headline(
              child: Text(
                pageDescription,
                style: OWATextStyles.sectionSubtitle,
              ),
            ),
          ),

          SizedBox(height: _gapDescToList),

          // ==================================================
          // ===== 2) MAIN CONTENT: LIST + IMG ===============
          // ==================================================
          SizedBox(
            width: _figDividerW,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------------------------------------------------
                // BLOQUE IZQUIERDO (Con altura forzada igual a la derecha)
                // ---------------------------------------------------------
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      /// Main content
                      Expanded(
                        child: Container(
                          width: _leftColW,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...therapiesList.map(
                                (t) =>
                                    _buildTherapyRow(t.therapyName, therapyMap),
                              ),
                              SizedBox(height: s(40)),
                            ],
                          ),
                        ),
                      ),

                      /// Space
                      SizedBox(
                        width: SizeConfig.w(772.54 - (507.50439453125 + 42)),
                      ),
                    ],
                  ),
                ),

                // ---------------------------------------------------------
                // IMAGEN DERECHA
                // ---------------------------------------------------------
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: _imageTopOffset),
                        child: SizedBox(
                          width: _imageW,
                          height: _imageH,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(_imageRadius),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 600),
                              switchInCurve: Curves.easeIn,
                              switchOutCurve: Curves.easeOut,
                              layoutBuilder: (
                                Widget? currentChild,
                                List<Widget> previousChildren,
                              ) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    ...previousChildren,
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                              transitionBuilder: (
                                Widget child,
                                Animation<double> animation,
                              ) {
                                final fadeAnimation = CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut,
                                );
                                return FadeTransition(
                                  opacity: fadeAnimation,
                                  child: child,
                                );
                              },
                              child: Image.network(
                                therapyMap[_selectedTherapy]
                                        ?.therapyImage
                                        .url ??
                                    '',
                                key: ValueKey(_selectedTherapy),
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // SizedBox(height: s(64)), // 3066 - (2293.79 + 649.38) = 122.83
          SizedBox(height: 3066 - (2293.79 + 649.38)),
          if (bookButtonUrl.isNotEmpty)
            // ===== CTA BUTTON =====
            Align(
              alignment: Alignment.center,
              child: OutlinedButton(
                onPressed: () async {
                  if (bookButtonUrl.isNotEmpty) {
                    final uri = Uri.parse(bookButtonUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.w(60),
                    vertical: SizeConfig.h(22),
                  ),
                ),
                child: Text(
                  bookButtonText,
                  style: TextStyle(
                    fontFamily: 'Arbeit',
                    color: Colors.black,
                    letterSpacing: 1.5,
                    fontSize: SizeConfig.t(10),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

          // SizedBox(height: s(60)),
          SizedBox(height: 3303 - (3066 + 43)),
        ],
      ),
    );
  }

  // ==========================
  // ===== HELPER WIDGETS =====
  // ==========================

  Widget _buildTherapyRow(
    String therapy,
    Map<String, OWATherapyItem> therapyMap,
  ) {
    final isExpanded = _expandedTherapy == therapy;
    final item = therapyMap[therapy];

    final titleStyle = TextStyle(
      fontFamily: 'Basier Square Mono',
      fontWeight: FontWeight.w400,
      fontSize: s(14),
      height: 0.90,
      letterSpacing: 0.12 * s(14),
      color: Colors.black,
      decoration: TextDecoration.none,
    );

    /// Compute from figma values
    final spaceBetweenRowsHeight = 2559.77 - (2407.06 + 60); // 92.71

    return SizedBox(
      width: _itemLineW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // HEADER (Slot 35px, Centrado, Box Text 13px, Nudge -1.2)
          // ==========================================
          SizedBox(
            width: _itemLineW,
            height: _itemHeaderH,
            child: Stack(
              children: [
                Positioned.fill(
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        _expandedTherapy = isExpanded ? null : therapy;
                        _selectedTherapy = therapy;
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tí­tulo en caja de 13px + Nudge
                        Transform.translate(
                          offset: Offset(0, _itemNudgeY),
                          child: SizedBox(
                            height: s(13),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(therapy, style: titleStyle),
                            ),
                          ),
                        ),
                        const Spacer(),

                        AnimatedMenuIconStack(
                          size: _plusBox,
                          color: Colors.black,
                          lineThickness: 0.7,
                          duration: Duration(milliseconds: 800),
                          isExpanded: !isExpanded,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                // Lí­nea divisoria fondo
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: _itemStroke,
                    color: const Color(0xFF656565),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // ACORDEÓN (Cuerpo)
          // ==========================================
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutQuart,
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints:
                    isExpanded
                        ? const BoxConstraints()
                        : const BoxConstraints(maxHeight: 0),
                child:
                    (item == null)
                        ? const SizedBox.shrink()
                        : Padding(
                          padding: EdgeInsets.only(top: s(21.2)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: _accDescW,
                                child: Text(
                                  item.therapyDescription,
                                  style: TextStyle(
                                    fontFamily: 'Times Now',
                                    fontWeight: FontWeight.w400,
                                    fontSize: SizeConfig.t(14),
                                    height: 20 / 14,
                                    color: Colors.black.withValues(alpha: 0.85),
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                              SizedBox(height: s(31.51)),
                              _buildBenefitsTwoColsFigma(item.benefits),
                              SizedBox(
                                height: SizeConfig.h(spaceBetweenRowsHeight),
                              ),
                            ],
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsTwoColsFigma(List<String> benefits) {
    final left = benefits.take(3).toList();
    final right = benefits.skip(3).take(2).toList();

    final style = TextStyle(
      fontFamily: 'Instrument Sans',
      fontWeight: FontWeight.w500,
      fontSize: SizeConfig.t(12),
      height: 20 / 12,
      color: Colors.black,
      decoration: TextDecoration.none,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            left.join('\n'),
            style: style,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
        SizedBox(width: _benefitsGap),
        Expanded(
          flex: 1,
          child: Text(
            right.join('\n'),
            style: style,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}
