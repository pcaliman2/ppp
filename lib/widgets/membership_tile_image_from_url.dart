import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/widgets/membership_card_image_from_url.dart';
import 'package:owa_flutter/widgets/membership_spec.dart';

class MembershipTile extends StatefulWidget {
  final MembershipSpec spec;
  final List<String> commonBenefits;
  final int index;
  final Set<int> selectedIndices;
  final ValueChanged<int> onSelectionChanged;
  final bool slowTextAnim;

  const MembershipTile({
    super.key,
    required this.spec,
    required this.commonBenefits,
    required this.index,
    required this.selectedIndices,
    required this.onSelectionChanged,
    this.slowTextAnim = false,
  });

  @override
  State<MembershipTile> createState() => _MembershipTileState();
}

class _MembershipTileState extends State<MembershipTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // ─── FORWARD (hover-in) curves ───────────────────────────────────────────
  // Title slides up: starts immediately, finishes at 55 %
  late Animation<double> _titleSlideForward;
  // Aux text fades in: starts at 45 %, finishes at 100 %
  late Animation<double> _auxFadeForward;

  // ─── REVERSE (hover-out) curves ──────────────────────────────────────────
  // Aux text fades out: controller goes 1→0, so we map 1.0→0.55
  late Animation<double> _auxFadeReverse;
  // Title slides back down: starts after aux fade, maps 0.55→0.0
  late Animation<double> _titleSlideReverse;

  // The unified value exposed to the card / description builder.
  // We drive them from a single _controller and pick the right curve
  // depending on direction via a custom Animatable.
  late Animation<double> _titleSlide; // 0 = center, 1 = shifted up
  late Animation<double> _auxFade; // 0 = invisible, 1 = visible

  @override
  void initState() {
    super.initState();

    final totalDuration =
        widget.slowTextAnim
            ? const Duration(milliseconds: 950)
            : const Duration(milliseconds: 650);

    _controller = AnimationController(
      duration: totalDuration,
      reverseDuration: totalDuration,
      vsync: this,
    );

    _buildAnimations();

    if (isSelected) _controller.value = 1.0;

    // Rebuild so the card can read the animation values.
    _controller.addListener(() => setState(() {}));
  }

  void _buildAnimations() {
    // ── Forward ──
    _titleSlideForward = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );

    _auxFadeForward = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
    );

    // ── Reverse ──
    // In reverse the controller goes from 1 → 0.
    // Interval(0.45, 1.0) in forward == Interval(0.0, 0.55) in reverse space.
    _auxFadeReverse = CurvedAnimation(
      parent: _controller,
      reverseCurve: const Interval(0.0, 0.55, curve: Curves.easeInCubic),
      curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
    );

    _titleSlideReverse = CurvedAnimation(
      parent: _controller,
      reverseCurve: const Interval(0.45, 1.0, curve: Curves.easeInCubic),
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(MembershipTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasSelected = oldWidget.selectedIndices.contains(widget.index);
    if (wasSelected != isSelected) {
      if (isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get isSelected => widget.selectedIndices.contains(widget.index);

  // ─── Derived values ───────────────────────────────────────────────────────

  /// 0 → 1   forward: title moves up; reverse: title moves back down
  double get _titleProgress {
    final isForward =
        _controller.status == AnimationStatus.forward ||
        _controller.status == AnimationStatus.completed;
    return isForward ? _titleSlideForward.value : _titleSlideReverse.value;
  }

  /// 0 → 1   forward: aux fades in; reverse: aux fades out first
  double get _auxOpacity {
    final isForward =
        _controller.status == AnimationStatus.forward ||
        _controller.status == AnimationStatus.completed;
    return isForward ? _auxFadeForward.value : _auxFadeReverse.value;
  }

  // ─── Description widget (below card) ─────────────────────────────────────

  Widget _buildCardDescription({
    required String price,
    required String mainDescription,
    required List<String> benefits,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          price,
          style: TextStyle(
            fontSize: SizeConfig.t(14),
            fontWeight: FontWeight.w600,
            color: Colors.black,
            height: 1.4,
          ),
        ),
        SizedBox(height: SizeConfig.h(16)),
        Text(
          mainDescription,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.5,
            color: Colors.black,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
        ...benefits.map(
          (b) => Padding(
            padding: EdgeInsets.only(bottom: SizeConfig.h(4)),
            child: Text(
              b,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                height: 20 / 12,
                color: Colors.black,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // How many logical pixels the title shifts upward at full hover.
    // MembershipCard must accept [titleOffset] and apply it internally.
    const double maxTitleShift = 18.0; // tweak to taste
    final double titleDy = -_titleProgress * maxTitleShift;

    // Aux description height-factor & opacity (below the card)
    const double auxHeight = 1.0;
    const double auxOpacity = 1.0;

    return SizedBox(
      width: SizeConfig.w(444),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card ──────────────────────────────────────────────────────────
          MembershipCard(
            number: widget.spec.number,
            title: widget.spec.title,
            price: widget.spec.price,
            imagePath: widget.spec.imagePath,
            size: 444,
            collapsedRadius: 0,
            borderRadiusValue: 10,
            onTap: () {
              widget.onSelectionChanged(widget.index);
              widget.spec.onTap();
            },
            isSelected: isSelected,
            // // Pass the animated vertical offset so MembershipCard can
            // // translate only the title label. If your MembershipCard does
            // // not yet accept this param, see the note below.
            // titleVerticalOffset: titleDy,
          ),
          SizedBox(height: SizeConfig.h(18)),

          SizedBox(height: SizeConfig.h(18)),
          _buildCardDescription(
            price: widget.spec.price,
            mainDescription: widget.spec.mainDescription,
            benefits: widget.spec.benefits ?? widget.commonBenefits,
          ),
        ],
      ),
    );
  }
}
