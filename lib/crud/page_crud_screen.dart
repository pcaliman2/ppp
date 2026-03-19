import 'package:flutter/material.dart';
import 'package:owa_flutter/crud/models.dart';
import 'dart:async';

class SectionsCRUDScreen extends StatefulWidget {
  final PageSpec pageSpec;
  final Function(PageSpec) onPageUpdated;

  const SectionsCRUDScreen({
    super.key,
    required this.pageSpec,
    required this.onPageUpdated,
  });

  @override
  State<SectionsCRUDScreen> createState() => _SectionsCRUDScreenState();
}

class _SectionsCRUDScreenState extends State<SectionsCRUDScreen>
    with TickerProviderStateMixin {
  late PageSpec currentPageSpec;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Colors
  static const backgroundColor = Color.fromRGBO(239, 236, 228, 1.0);
  // static const onHoverButtonColor = Color(0xFFE3FE23);

  @override
  void initState() {
    super.initState();
    currentPageSpec = widget.pageSpec;

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Setup animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _slideController.forward();
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildCustomHeader(),

            // Content
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildContent(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  _AnimatedNavButton(
                    text: 'BACK',
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                  // Center Title
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'O',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 3.0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'W',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 3.0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'A°',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 3.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CONTENT MANAGEMENT',
                        style: TextStyle(
                          fontFamily: 'Basier Square Mono',
                          fontSize: 8,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      _AnimatedNavButton(
                        text: 'ADD SECTION',
                        icon: Icons.add,
                        onPressed: _showAddSectionDialog,
                      ),
                      const SizedBox(width: 20),
                      _AnimatedActionButton(text: 'SAVE', onPressed: _savePage),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Info Card
          _buildPageInfoCard(),

          const SizedBox(height: 32),

          // Sections Header
          _buildSectionsHeader(),

          const SizedBox(height: 24),

          // Sections List
          Expanded(child: _buildSectionsList()),
        ],
      ),
    );
  }

  Widget _buildPageInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.web, color: Colors.grey[700], size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                'PAGE INFORMATION',
                style: TextStyle(
                  fontFamily: 'Basier Square Mono',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.0,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'TITLE',
                  currentPageSpec.snapshot.page.title,
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _buildInfoItem(
                  'SLUG',
                  '/${currentPageSpec.snapshot.page.slug}',
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _buildInfoItem(
                  'STATUS',
                  currentPageSpec.state.toUpperCase(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Basier Circle Mono',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionsHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.view_module, color: Colors.grey[700], size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SECTIONS',
              style: TextStyle(
                fontFamily: 'Basier Square Mono',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${currentPageSpec.snapshot.sections.length} items',
              style: TextStyle(
                fontFamily: 'Basier Circle Mono',
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          'Drag to reorder',
          style: TextStyle(
            fontFamily: 'Basier Circle Mono',
            fontSize: 10,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionsList() {
    if (currentPageSpec.snapshot.sections.isEmpty) {
      return _buildEmptyState();
    }

    return ReorderableListView.builder(
      itemCount: currentPageSpec.snapshot.sections.length,
      onReorder: _reorderSections,
      itemBuilder: (context, index) {
        final section = currentPageSpec.snapshot.sections[index];
        return _buildSectionCard(section, index);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.widgets_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'NO SECTIONS YET',
            style: TextStyle(
              fontFamily: 'Basier Square Mono',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 2.0,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first section to get started',
            style: TextStyle(
              fontFamily: 'Basier Circle Mono',
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          _AnimatedActionButton(
            text: 'ADD FIRST SECTION',
            onPressed: _showAddSectionDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(Section section, int index) {
    final sectionIcon = _getSectionIcon(section.type);
    final sectionColor = _getSectionColor(section.type);

    return Card(
      key: ValueKey(section.id),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: _AnimatedSectionTile(
        section: section,
        index: index,
        sectionIcon: sectionIcon,
        sectionColor: sectionColor,
        onEdit: () => _editSection(section, index),
        onDelete: () => _deleteSection(index),
      ),
    );
  }

  IconData _getSectionIcon(String sectionType) {
    switch (sectionType) {
      case 'NavBar':
        return Icons.menu;
      case 'HeroTwoUp':
      case 'HeroMediaOverlay':
        return Icons.landscape;
      case 'IntroBlurbCTAs':
        return Icons.text_fields;
      case 'DiscoverGrid':
        return Icons.grid_view;
      case 'TherapiesAccordion':
        return Icons.expand_more;
      case 'MembershipsGrid':
        return Icons.card_membership;
      case 'SocialGallery':
        return Icons.photo_library;
      case 'Footer':
        return Icons.web_asset;
      default:
        return Icons.widgets;
    }
  }

  Color _getSectionColor(String sectionType) {
    switch (sectionType) {
      case 'NavBar':
        return Colors.blue;
      case 'HeroTwoUp':
      case 'HeroMediaOverlay':
        return Colors.purple;
      case 'IntroBlurbCTAs':
        return Colors.green;
      case 'DiscoverGrid':
        return Colors.orange;
      case 'TherapiesAccordion':
        return Colors.teal;
      case 'MembershipsGrid':
        return Colors.indigo;
      case 'SocialGallery':
        return Colors.pink;
      case 'Footer':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  // String _getSectionDescription(Section section) {
  //   switch (section.type) {
  //     case 'NavBar':
  //       final data = NavBarData.fromMap(section.data);
  //       return 'Brand: ${data.brand.text} • ${data.leftLinks.length + data.rightLinks.length} links';
  //     case 'HeroTwoUp':
  //       final data = HeroTwoUpData.fromMap(section.data);
  //       return '${data.media.length} media items • ${data.overlay.rotatingWords.length} rotating words';
  //     case 'HeroMediaOverlay':
  //       final data = HeroMediaOverlayData.fromMap(section.data);
  //       return '${data.media.length} media items • ${data.overlay.rotatingWords.length} rotating words';
  //     case 'IntroBlurbCTAs':
  //       final data = IntroBlurbCTAsData.fromMap(section.data);
  //       return '${data.heading} • ${data.ctas.length} CTAs';
  //     case 'DiscoverGrid':
  //       final data = DiscoverGridData.fromMap(section.data);
  //       return '${data.title} • ${data.items.length} items';
  //     case 'TherapiesAccordion':
  //       final data = TherapiesAccordionData.fromMap(section.data);
  //       return '${data.title} • ${data.items.length} therapies';
  //     case 'MembershipsGrid':
  //       final data = MembershipsGridData.fromMap(section.data);
  //       return '${data.title} • ${data.items.length} membership options';
  //     case 'SocialGallery':
  //       final data = SocialGalleryData.fromMap(section.data);
  //       return '${data.handle} • ${data.images.length} images';
  //     case 'Footer':
  //       final data = FooterData.fromMap(section.data);
  //       return '${data.title} • ${data.groups.length} groups';
  //     default:
  //       return 'Custom section configuration';
  //   }
  // }

  void _reorderSections(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final sections = List<Section>.from(currentPageSpec.snapshot.sections);
      final item = sections.removeAt(oldIndex);
      sections.insert(newIndex, item);

      // Update positions
      for (int i = 0; i < sections.length; i++) {
        sections[i] = Section(
          id: sections[i].id,
          type: sections[i].type,
          position: i + 1,
          schemaVersion: sections[i].schemaVersion,
          data: sections[i].data,
        );
      }

      currentPageSpec = PageSpec(
        pageId: currentPageSpec.pageId,
        state: currentPageSpec.state,
        snapshot: PageSnapshot(
          page: currentPageSpec.snapshot.page,
          sections: sections,
        ),
      );
    });
  }

  void _editSection(Section section, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SectionEditScreen(
              section: section,
              onSectionUpdated: (updatedSection) {
                setState(() {
                  final sections = List<Section>.from(
                    currentPageSpec.snapshot.sections,
                  );
                  sections[index] = updatedSection;
                  currentPageSpec = PageSpec(
                    pageId: currentPageSpec.pageId,
                    state: currentPageSpec.state,
                    snapshot: PageSnapshot(
                      page: currentPageSpec.snapshot.page,
                      sections: sections,
                    ),
                  );
                });
              },
            ),
      ),
    );
  }

  void _deleteSection(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _CustomDialog(
          title: 'DELETE SECTION',
          content:
              'Are you sure you want to delete this section? This action cannot be undone.',
          onConfirm: () {
            setState(() {
              final sections = List<Section>.from(
                currentPageSpec.snapshot.sections,
              );
              sections.removeAt(index);

              // Update positions
              for (int i = 0; i < sections.length; i++) {
                sections[i] = Section(
                  id: sections[i].id,
                  type: sections[i].type,
                  position: i + 1,
                  schemaVersion: sections[i].schemaVersion,
                  data: sections[i].data,
                );
              }

              currentPageSpec = PageSpec(
                pageId: currentPageSpec.pageId,
                state: currentPageSpec.state,
                snapshot: PageSnapshot(
                  page: currentPageSpec.snapshot.page,
                  sections: sections,
                ),
              );
            });
            Navigator.of(context).pop();
          },
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void _showAddSectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AddSectionDialog(
          onSectionSelected: (sectionType) {
            Navigator.of(context).pop();
            _addNewSection(sectionType);
          },
          getSectionIcon: _getSectionIcon,
          getSectionColor: _getSectionColor,
        );
      },
    );
  }

  void _addNewSection(String sectionType) {
    final newSection = Section(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: sectionType,
      position: currentPageSpec.snapshot.sections.length + 1,
      schemaVersion: 1,
      data: _getDefaultSectionData(sectionType),
    );

    final sections = List<Section>.from(currentPageSpec.snapshot.sections);

    setState(() {
      sections.add(newSection);
      currentPageSpec = PageSpec(
        pageId: currentPageSpec.pageId,
        state: currentPageSpec.state,
        snapshot: PageSnapshot(
          page: currentPageSpec.snapshot.page,
          sections: sections,
        ),
      );
    });

    // Automatically open the edit screen for the new section
    _editSection(newSection, sections.length - 1);
  }

  Map<String, dynamic> _getDefaultSectionData(String sectionType) {
    switch (sectionType) {
      case 'NavBar':
        return {
          'brand': {'href': '/', 'text': 'Brand'},
          'leftLinks': [],
          'rightLinks': [],
        };
      case 'IntroBlurbCTAs':
        return {
          'heading': 'New Heading',
          'body': 'New content here...',
          'align': 'center',
          'ctas': [],
        };
      default:
        return {};
    }
  }

  void _savePage() {
    widget.onPageUpdated(currentPageSpec);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'PAGE SAVED SUCCESSFULLY',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// Custom Animated Navigation Button
class _AnimatedNavButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;

  const _AnimatedNavButton({
    required this.text,
    this.icon,
    required this.onPressed,
  });

  @override
  State<_AnimatedNavButton> createState() => _AnimatedNavButtonState();
}

class _AnimatedNavButtonState extends State<_AnimatedNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.grey[700], size: 14),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontFamily: 'Basier Square Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
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
                      decoration: BoxDecoration(color: Colors.grey[700]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getTextWidth() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: TextStyle(
          fontFamily: 'Basier Square Mono',
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.0,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }
}

// Custom Animated Action Button
class _AnimatedActionButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const _AnimatedActionButton({required this.text, required this.onPressed});

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<Color?> _colorAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.black87,
      end: const Color(0xFFE3FE23),
    ).animate(_hoverController);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: widget.onPressed,
              child: Text(
                widget.text,
                style: TextStyle(
                  fontFamily: 'Basier Square Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  color: _isHovered ? Colors.black : Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom Animated Section Tile
class _AnimatedSectionTile extends StatefulWidget {
  final Section section;
  final int index;
  final IconData sectionIcon;
  final Color sectionColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AnimatedSectionTile({
    required this.section,
    required this.index,
    required this.sectionIcon,
    required this.sectionColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_AnimatedSectionTile> createState() => _AnimatedSectionTileState();
}

class _AnimatedSectionTileState extends State<_AnimatedSectionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  String _getSectionDescription(Section section) {
    // Simplified description logic
    switch (section.type) {
      case 'NavBar':
        return 'Navigation component';
      case 'HeroTwoUp':
      case 'HeroMediaOverlay':
        return 'Hero section with media';
      case 'IntroBlurbCTAs':
        return 'Introduction with call-to-actions';
      default:
        return 'Custom section';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value / 2),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onEdit,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Drag Handle
                    Icon(Icons.drag_handle, color: Colors.grey[400], size: 18),
                    const SizedBox(width: 16),

                    // Section Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.sectionColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.sectionIcon,
                        color: widget.sectionColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Section Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.section.type,
                                style: TextStyle(
                                  fontFamily: 'Basier Circle Mono',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'POS ${widget.section.position}',
                                  style: TextStyle(
                                    fontFamily: 'Basier Square Mono',
                                    fontSize: 8,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getSectionDescription(widget.section),
                            style: TextStyle(
                              fontFamily: 'Basier Circle Mono',
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _IconButton(
                          icon: Icons.edit_outlined,
                          color: Colors.blue,
                          onPressed: widget.onEdit,
                          tooltip: 'Edit Section',
                        ),
                        const SizedBox(width: 8),
                        _IconButton(
                          icon: Icons.delete_outline,
                          color: Colors.red,
                          onPressed: widget.onDelete,
                          tooltip: 'Delete Section',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom Icon Button
class _IconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  const _IconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: Tooltip(
        message: widget.tooltip,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: widget.onPressed,
                    child: Icon(widget.icon, color: widget.color, size: 16),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Custom Dialog
class _CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _CustomDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromRGBO(239, 236, 228, 1.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Basier Square Mono',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Basier Circle Mono',
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _AnimatedActionButton(
                    text: 'CANCEL',
                    onPressed: onCancel,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onConfirm,
                      child: Text(
                        'DELETE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Basier Square Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Add Section Dialog
class _AddSectionDialog extends StatelessWidget {
  final Function(String) onSectionSelected;
  final IconData Function(String) getSectionIcon;
  final Color Function(String) getSectionColor;

  const _AddSectionDialog({
    required this.onSectionSelected,
    required this.getSectionIcon,
    required this.getSectionColor,
  });

  @override
  Widget build(BuildContext context) {
    final sectionTypes = [
      'NavBar',
      'HeroTwoUp',
      'HeroMediaOverlay',
      'IntroBlurbCTAs',
      'DiscoverGrid',
      'TherapiesAccordion',
      'MembershipsGrid',
      'SocialGallery',
      'Footer',
    ];

    return Dialog(
      backgroundColor: const Color.fromRGBO(239, 236, 228, 1.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ADD NEW SECTION',
              style: TextStyle(
                fontFamily: 'Basier Square Mono',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the type of section you want to add',
              style: TextStyle(
                fontFamily: 'Basier Circle Mono',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  children:
                      sectionTypes.map((type) {
                        return _SectionTypeItem(
                          type: type,
                          icon: getSectionIcon(type),
                          color: getSectionColor(type),
                          onTap: () => onSectionSelected(type),
                        );
                      }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _AnimatedActionButton(
              text: 'CANCEL',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// Section Type Item
class _SectionTypeItem extends StatefulWidget {
  final String type;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SectionTypeItem({
    required this.type,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_SectionTypeItem> createState() => _SectionTypeItemState();
}

class _SectionTypeItemState extends State<_SectionTypeItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.color.withValues(alpha: 0.1),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: widget.color, size: 20),
              ),
              title: Text(
                widget.type,
                style: TextStyle(
                  fontFamily: 'Basier Circle Mono',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              onTap: widget.onTap,
            ),
          );
        },
      ),
    );
  }
}

// Placeholder for the section edit screen (styled to match)
class SectionEditScreen extends StatelessWidget {
  final Section section;
  final Function(Section) onSectionUpdated;

  const SectionEditScreen({
    super.key,
    required this.section,
    required this.onSectionUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(239, 236, 228, 1.0),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _AnimatedNavButton(
                    text: 'BACK',
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'EDIT ${section.type.toUpperCase()}',
                    style: TextStyle(
                      fontFamily: 'Basier Square Mono',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  _AnimatedActionButton(
                    text: 'SAVE',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(64),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.construction_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'SECTION EDITOR',
                        style: TextStyle(
                          fontFamily: 'Basier Square Mono',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Form components for ${section.type} will be implemented here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Basier Circle Mono',
                          fontSize: 12,
                          color: Colors.grey[500],
                          height: 1.5,
                        ),
                      ),
                    ],
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
