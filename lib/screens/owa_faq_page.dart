import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:owa_flutter/screens/faq_spec.dart';
import 'package:owa_flutter/screens/faq_spec_.dart';
import 'package:owa_flutter/screens/owa_nav_bar.dart';
import 'package:owa_flutter/useful/colors.dart';
import 'package:owa_flutter/useful/is_desktop_from_context.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful_widgets/animated_menu_icon_stack.dart';
import 'package:owa_flutter/widgets/footer_section.dart';
import 'package:owa_flutter/widgets/mobile_footer.dart';
import 'package:owa_flutter/widgets/owa_drawer.dart';
import 'package:owa_flutter/widgets/whatsapp_floating_button.dart';

// ---------------------------------------------------------------------------
// Section grouping — maps a display label to a list of question substrings
// that belong to that section. Order matters: it defines the left-nav order.
// ---------------------------------------------------------------------------

class _FaqSection {
  final String label;

  /// If null → catches everything not matched by a prior section (i.e. "General")
  final List<String>? keywords;

  const _FaqSection({required this.label, this.keywords});
}

const List<_FaqSection> _kSections = [
  _FaqSection(label: 'General', keywords: null),
  _FaqSection(
    label: 'Sauna',
    keywords: ['sauna', 'entering', 'social sauna', 'private sauna'],
  ),
  _FaqSection(
    label: 'Cold Plunge',
    keywords: [
      'cold plunge',
      'temperature',
      'how long should i stay',
      'safe for beginners',
      'what are the benefits', // cold plunge benefits
    ],
  ),
  _FaqSection(
    label: 'Zero Gravity Chair',
    keywords: [
      'zero gravity',
      'how long does it last',
      'what does it feel like',
    ],
  ),
  _FaqSection(label: 'Shiftwave', keywords: ['shiftwave']),
  _FaqSection(
    label: 'Pressotherapy',
    keywords: ['pressotherapy', 'invasive', 'rhino kit'],
  ),
  _FaqSection(
    label: 'Memberships',
    keywords: [
      'core, signature',
      'membership',
      'visits include',
      'unused visits',
      'minimum commitment',
      'share my membership',
      'membership prices',
      'cancel my membership',
      'pause or cancel',
    ],
  ),
  _FaqSection(
    label: 'Bookings',
    keywords: [
      'book a therapy',
      'arrive late',
      'cancellation policy',
      'bring guests',
      'how far in advance',
      'reschedule',
      'do i need to be a member',
    ],
  ),
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Assigns each FaqItem to its best-matching section index.
/// Returns a map: sectionIndex → list of FaqItems.
Map<int, List<FaqItem>> _groupFaqs(List<FaqItem> faqs) {
  // Sections that have explicit keywords, in order
  final keywordSections =
      _kSections
          .asMap()
          .entries
          .where((e) => e.value.keywords != null)
          .toList();

  // Index of the "General" catch-all section
  final generalIndex = _kSections.indexWhere((s) => s.keywords == null);

  final Map<int, List<FaqItem>> result = {
    for (var i = 0; i < _kSections.length; i++) i: [],
  };

  // Track which FAQs have been claimed by a keyword section to avoid
  // double-counting "What are the benefits?" which appears multiple times.
  final claimed = <int>{};

  for (final sectionEntry in keywordSections) {
    final sectionIdx = sectionEntry.key;
    final keywords = sectionEntry.value.keywords!;

    for (var i = 0; i < faqs.length; i++) {
      if (claimed.contains(i)) continue;
      final q = faqs[i].question.toLowerCase();
      if (keywords.any((kw) => q.contains(kw.toLowerCase()))) {
        result[sectionIdx]!.add(faqs[i]);
        claimed.add(i);
      }
    }
  }

  // Anything unclaimed goes to General
  for (var i = 0; i < faqs.length; i++) {
    if (!claimed.contains(i)) {
      result[generalIndex]!.add(faqs[i]);
    }
  }

  return result;
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class OWAFAQPageParallaxV3 extends StatefulWidget {
  const OWAFAQPageParallaxV3({super.key});

  @override
  State<OWAFAQPageParallaxV3> createState() => _OWAFAQPageParallaxV3State();
}

class _OWAFAQPageParallaxV3State extends State<OWAFAQPageParallaxV3>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _controller = ScrollController();
  final GlobalKey _footerKey = GlobalKey();
  final GlobalKey _footerMobileKey = GlobalKey();

  double _lastOffset = 0.0;
  bool _isNavbarVisible = true;

  // Navbar animations
  late AnimationController _navController;
  late Animation<double> _navFadeAnimation;
  late Animation<Offset> _navSlideAnimation;
  late AnimationController _navVisibilityController;
  late Animation<Offset> _navVisibilityAnimation;

  // FAQ state
  FaqSpec? _faqSpec;
  bool _isLoading = true;
  int _selectedSectionIndex = 0;
  Map<int, List<FaqItem>> _groupedFaqs = {};
  double _desktopFooterHeight = 539;
  double _mobileFooterHeight = 0;
  bool _footerSyncScheduled = false;

  // Content fade animation
  late AnimationController _contentFadeController;
  late Animation<double> _contentFadeAnimation;

  static const String _apiUrl =
      'https://www.latente-cms.com/delivery/v1/tenants/owa/sections/faq/entries/faq';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleScroll);
    _initNavAnimations();
    _initContentFadeAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFaqSpec();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _navController.forward();
      });
    });
  }

  void _initNavAnimations() {
    _navController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _navFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _navController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _navSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _navController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _navVisibilityController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navVisibilityAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _navVisibilityController,
        curve: Curves.easeInOut,
      ),
    );
    _navVisibilityController.value = 1.0;
  }

  void _initContentFadeAnimation() {
    _contentFadeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentFadeController, curve: Curves.easeInOut),
    );
    _contentFadeController.value = 1.0;
  }

  Future<void> _loadFaqSpec() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final spec = FaqSpec.fromMap(jsonData);
        setState(() {
          _faqSpec = spec;
          _groupedFaqs = _groupFaqs(spec.data.faqs);
          _isLoading = false;
        });
        _contentFadeController.forward(from: 0);
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading FAQ spec: $e');
      // Fallback to local map
      final spec = FaqSpec.fromMap(faqSpecMap);
      setState(() {
        _faqSpec = spec;
        _groupedFaqs = _groupFaqs(spec.data.faqs);
        _isLoading = false;
      });
      _contentFadeController.forward(from: 0);
    }
  }

  void _selectSection(int index) async {
    if (_selectedSectionIndex == index) return;
    // Fade out
    await _contentFadeController.reverse();
    setState(() => _selectedSectionIndex = index);
    // Fade in
    _contentFadeController.forward();
  }

  void _handleScroll() {
    final double currentOffset = _controller.offset;
    final double delta = currentOffset - _lastOffset;
    const double scrollThreshold = 10.0;

    if (delta.abs() > scrollThreshold) {
      if (delta > 0 && _isNavbarVisible) {
        _isNavbarVisible = false;
        _navVisibilityController.reverse();
      } else if (delta < 0 && !_isNavbarVisible) {
        _isNavbarVisible = true;
        _navVisibilityController.forward();
      }
      _lastOffset = currentOffset;
    }
  }

  void _syncFooterHeights() {
    if (_footerSyncScheduled) return;
    _footerSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _footerSyncScheduled = false;
      if (!mounted) return;

      final desktopHeight = _footerKey.currentContext?.size?.height;
      final mobileHeight = _footerMobileKey.currentContext?.size?.height;
      final hasDesktopChange =
          desktopHeight != null &&
          desktopHeight > 0 &&
          (desktopHeight - _desktopFooterHeight).abs() > 0.5;
      final hasMobileChange =
          mobileHeight != null &&
          mobileHeight > 0 &&
          (mobileHeight - _mobileFooterHeight).abs() > 0.5;

      if (hasDesktopChange || hasMobileChange) {
        setState(() {
          if (hasDesktopChange) _desktopFooterHeight = desktopHeight!;
          if (hasMobileChange) _mobileFooterHeight = mobileHeight!;
        });
      }
    });
  }

  double _footerRevealProgress(double footerHeight) {
    if (!_controller.hasClients) return 0.0;

    final position = _controller.position;
    if (!position.hasContentDimensions) return 0.0;

    if (footerHeight <= 0) return 0.0;

    final maxScroll = position.maxScrollExtent;
    final revealStart = (maxScroll - footerHeight).clamp(
      position.minScrollExtent,
      maxScroll,
    );
    final rawProgress = (position.pixels - revealStart) / footerHeight;
    return rawProgress.clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _navController.dispose();
    _navVisibilityController.dispose();
    _contentFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDesktopFromContext(context);
    final double footerHeight =
        isDesktop
            ? _desktopFooterHeight
            : (_mobileFooterHeight > 0 ? _mobileFooterHeight : 640.0);
    final footerWidget =
        isDesktop
            ? OWAFooter(key: _footerKey)
            : OWAMobileFooter(key: _footerMobileKey);

    _syncFooterHeights();

    return Scaffold(
      key: _scaffoldKey,
      drawer: !isDesktop ? OWADrawer() : null,
      backgroundColor: backgroundColor,
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: WhatsAppFloatingButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          Positioned.fill(
            child: Scrollbar(
              controller: _controller,
              thumbVisibility: isDesktop,
              interactive: true,
              child: SingleChildScrollView(
                controller: _controller,
                physics:
                    isDesktop
                        ? const ClampingScrollPhysics()
                        : const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                child: Column(
                  children: [
                    Container(
                      color: backgroundColor,
                      child: SelectionArea(
                        child:
                            isDesktop
                                ? _buildFaqDesktopBody()
                                : _buildFaqMobileBody(),
                      ),
                    ),
                    SizedBox(height: footerHeight),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _controller,
              child: RepaintBoundary(child: footerWidget),
              builder: (context, child) {
                final progress = Curves.easeOut.transform(
                  _footerRevealProgress(footerHeight),
                );
                return Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerSignal: _forwardFooterWheel,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: progress,
                      child: child,
                    ),
                  ),
                );
              },
            ),
          ),
          _buildFixedNavbar(),
        ],
      ),
    );
  }

  void _forwardFooterWheel(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) return;
    final position = _controller.position;
    if (!position.hasContentDimensions) return;
    final target = (position.pixels + event.scrollDelta.dy).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    ).toDouble();
    if ((target - position.pixels).abs() < 0.5) return;
    _controller.jumpTo(target);
  }

  // ── Navbar ────────────────────────────────────────────────────────────────

  Widget _buildFixedNavbar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _navFadeAnimation,
            _navVisibilityAnimation,
          ]),
          builder: (context, child) {
            return SlideTransition(
              position: _navVisibilityAnimation,
              child: FadeTransition(
                opacity: _navFadeAnimation,
                child: SlideTransition(
                  position: _navSlideAnimation,
                  child:
                      isDesktopFromContext(context)
                          ? OWANavbarDesktop(
                            onLogoTap: _goToLandingPage,
                            onNavTap: _onNavTap,
                          )
                          : OWANavbarDesktop(
                            onLogoTap: _goToLandingPage,
                            onNavTap: _onNavTap,
                          ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Desktop layout ────────────────────────────────────────────────────────

  void _goToLandingPage() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _onNavTap(String label) {
    switch (label) {
      case 'Memberships':
      case 'Services':
      case 'Therapies':
      case 'Contact':
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
          arguments: {'section': label},
        );
        break;
      case 'FAQ':
        break;
    }
  }

  Widget _buildFaqDesktopBody() {
    if (_isLoading) {
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final currentFaqs = _groupedFaqs[_selectedSectionIndex] ?? [];

    return Padding(
      padding: const EdgeInsets.only(
        left: 44,
        right: 44,
        top: 120, // space below navbar
        bottom: 80,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left sidebar ─────────────────────────────────────────────
          SizedBox(
            width: 200,
            child: _FaqSideNav(
              sections: _kSections,
              selectedIndex: _selectedSectionIndex,
              onSectionTap: _selectSection,
            ),
          ),

          const SizedBox(width: 80),

          // ── Right content ─────────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _contentFadeAnimation,
              child: _FaqContentPanel(
                pageTitle: _faqSpec!.data.pageTitle,
                faqs: currentFaqs,
                sectionLabel: _kSections[_selectedSectionIndex].label,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile layout ─────────────────────────────────────────────────────────

  Widget _buildFaqMobileBody() {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final currentFaqs = _groupedFaqs[_selectedSectionIndex] ?? [];

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 100, bottom: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal scrollable section tabs on mobile
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _kSections.length,
              separatorBuilder: (_, __) => const SizedBox(width: 24),
              itemBuilder: (context, i) {
                final selected = i == _selectedSectionIndex;
                return GestureDetector(
                  onTap: () => _selectSection(i),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      fontFamily: 'UncutSans',
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                      color:
                          selected
                              ? const Color(0xFF2C2B27)
                              : const Color(0xFF888880),
                      letterSpacing: 0.4,
                    ),
                    child: Text(_kSections[i].label),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          FadeTransition(
            opacity: _contentFadeAnimation,
            child: _FaqContentPanel(
              pageTitle: _faqSpec!.data.pageTitle,
              faqs: currentFaqs,
              sectionLabel: _kSections[_selectedSectionIndex].label,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Left sidebar nav
// ─────────────────────────────────────────────────────────────────────────────

class _FaqSideNav extends StatelessWidget {
  final List<_FaqSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onSectionTap;

  const _FaqSideNav({
    required this.sections,
    required this.selectedIndex,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < sections.length; i++)
          _SideNavItem(
            label: sections[i].label,
            isSelected: i == selectedIndex,
            onTap: () => onSectionTap(i),
          ),
      ],
    );
  }
}

class _SideNavItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SideNavItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SideNavItem> createState() => _SideNavItemState();
}

class _SideNavItemState extends State<_SideNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected || _isHovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontFamily: 'UncutSans',
              fontSize: 14,
              fontWeight: widget.isSelected ? FontWeight.w500 : FontWeight.w400,
              color: active ? const Color(0xFF2C2B27) : const Color(0xFF888880),
              letterSpacing: 0.2,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Right content panel — page title + FAQ accordion list
// ─────────────────────────────────────────────────────────────────────────────

class _FaqContentPanel extends StatelessWidget {
  final String pageTitle;
  final List<FaqItem> faqs;
  final String sectionLabel;

  const _FaqContentPanel({
    required this.pageTitle,
    required this.faqs,
    required this.sectionLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (faqs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Text(
          'No questions in this section yet.',
          style: TextStyle(
            fontFamily: 'UncutSans',
            fontSize: 15,
            color: Color(0xFF888880),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page title (e.g. "FAQ")
        Text(
          pageTitle,
          style: const TextStyle(
            fontFamily: 'UncutSans',
            fontWeight: FontWeight.w500,
            fontSize: 13,
            letterSpacing: 1.2,
            color: Color(0xFF888880),
          ),
        ),

        const SizedBox(height: 40),

        // FAQ items separated by dividers
        for (var i = 0; i < faqs.length; i++) ...[
          _FaqAccordionItem(item: faqs[i]),
          if (i < faqs.length - 1)
            Container(height: 1, color: const Color(0xFFD4D2C9)),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single expandable FAQ item
// ─────────────────────────────────────────────────────────────────────────────

class _FaqAccordionItem extends StatefulWidget {
  final FaqItem item;

  const _FaqAccordionItem({required this.item});

  @override
  State<_FaqAccordionItem> createState() => _FaqAccordionItemState();
}

class _FaqAccordionItemState extends State<_FaqAccordionItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isHovered = false;

  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  // Icono + / -
  double get _plusBox => SizeConfig.w(9.92) * 1.6;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          color:
              _isHovered && !_isExpanded
                  ? const Color(0x08000000)
                  : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: const TextStyle(
                        fontFamily: 'UncutSans',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 1.35,
                        color: Color(0xFF2C2B27),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedMenuIconStack(
                    size: _plusBox,
                    color: Colors.black,
                    lineThickness: 0.7,
                    duration: Duration(milliseconds: 800),
                    isExpanded: !_isExpanded,
                    onTap: () {},
                  ),
                  // +/– toggle indicator
                  // AnimatedRotation(
                  //   turns: _isExpanded ? 0.125 : 0, // 45° when expanded
                  //   duration: const Duration(milliseconds: 300),
                  //   curve: Curves.easeInOut,
                  //   child: const Icon(
                  //     Icons.add,
                  //     size: 18,
                  //     color: Color(0xFF2C2B27),
                  //   ),
                  // ),
                ],
              ),

              // Answer — animated size + fade
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1,
                child: FadeTransition(
                  opacity: _expandAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, right: 34),
                    child: Text(
                      widget.item.answer,
                      style: const TextStyle(
                        fontFamily: 'UncutSans',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        height: 1.55,
                        color: Color(0xFF555550),
                      ),
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
}
