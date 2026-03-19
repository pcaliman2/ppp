import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful_widgets/animated_arrow_icon.dart';

class MembershipCard extends StatefulWidget {
  final String? number;
  final String title;
  final String price;
  final String imagePath;
  final VoidCallback? onTap;

  /// Radio cuando está HOVERED (tu "premium")
  final double borderRadiusValue;

  /// Radio cuando NO está hovered (sharp)
  final double collapsedRadius;

  /// Tamaño base de la card (en tu caso 444). Se vuelve cuadrada.
  final double size;

  final bool isSelected;

  const MembershipCard({
    super.key,
    this.number,
    required this.title,
    required this.price,
    required this.imagePath,
    this.onTap,
    this.borderRadiusValue = 10.0,
    this.collapsedRadius = 0.0,
    this.size = 444,
    this.isSelected = false,
  });

  @override
  State<MembershipCard> createState() => _MembershipCardState();
}

class _MembershipCardState extends State<MembershipCard> {
  late bool _isHovered = widget.isSelected;
  late bool _isArrowHorizontal = widget.isSelected;

  @override
  void didUpdateWidget(covariant MembershipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _isArrowHorizontal = widget.isSelected;
      _isHovered = widget.isSelected || _isHovered;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = SizeConfig.w(widget.size);
    final h = w; // ✅ CUADRADA
    const highlight = Color(0xFFE6FD45);

    // ✅ Radio animado: sharp -> rounded al hacer hover
    final targetRadius =
        _isHovered ? widget.borderRadiusValue : widget.collapsedRadius;

    // ✅ Zoom del 2% en hover (como AnimatedProjectCard)
    final imageScale = _isHovered ? 1.02 : 1.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = widget.isSelected || false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutCubic,
          width: w,
          height: h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(targetRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.22 : 0.20),
                blurRadius: _isHovered ? 26 : 18,
                offset: Offset(0, _isHovered ? 10 : 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ✅ Imagen con zoom animado en hover
              _buildAnimatedImage(w, h, imageScale),

              // ✅ Overlay con backdrop blur cuando está hovered
              if (_isHovered) _buildBackdropOverlay(),

              // ✅ Overlay de opacidad base
              _buildOpacityOverlay(),

              // ✅ Contenido central con transición suave
              _buildCenterContent(highlight),

              // ✅ Número
              if (widget.number != null && widget.number!.trim().isNotEmpty)
                _buildNumberLabel(),

              // Flecha amarilla en esquina superior derecha solo en hover
              _buildHoverArrow(highlight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedImage(double w, double h, double scale) {
    return Positioned.fill(
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: w * scale,
          height: h * scale,
          child: Image.network(widget.imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildBackdropOverlay() {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildOpacityOverlay() {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        color: Colors.black.withValues(alpha: _isHovered ? 0.70 : 0.30),
      ),
    );
  }

  Widget _buildCenterContent(Color highlight) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Título con transición suave de opacidad
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontFamily: 'Basier Circle Mono',
                fontWeight: FontWeight.w400,
                fontSize: SizeConfig.t(24),
                color: Colors.white.withValues(alpha: _isHovered ? 1.0 : 0.95),
                letterSpacing: 2.0,
              ),
              child: Text(
                widget.title.toUpperCase(),
                textAlign: TextAlign.center,
              ),
            ),

            // ✅ Contenido expandible con AnimatedSize (muestra en hover)
            AnimatedSize(
              duration: const Duration(milliseconds: 820),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 860),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  );
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child:
                    _isHovered
                        ? Column(
                          key: const ValueKey('membership-details-visible'),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: SizeConfig.h(12)),
                            Text(
                              widget.price,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Basier Circle Mono',
                                fontWeight: FontWeight.w400,
                                fontSize: SizeConfig.t(16),
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: SizeConfig.h(6)),
                            Text(
                              "MEMBERSHIP",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Basier Square Mono',
                                fontSize: SizeConfig.t(10),
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        )
                        : const SizedBox.shrink(
                          key: ValueKey('membership-details-hidden'),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberLabel() {
    return Positioned(
      bottom: SizeConfig.h(16),
      left: SizeConfig.w(16),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: _isHovered ? 0.8 : 1.0,
        child: Text(
          widget.number!.trim(),
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w400,
            fontSize: SizeConfig.t(14),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHoverArrow(Color highlight) {
    return Positioned(
      top: SizeConfig.h(20),
      right: SizeConfig.w(20),
      child: AnimatedArrowIcon(
        width: 11,
        height: 9.81,
        assetPath: 'assets/icons/arrow_right.svg',
        isHovered: _isHovered,
      ),
    );
  }
}
