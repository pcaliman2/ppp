import 'package:flutter/material.dart';

class TeamMemberImage extends StatefulWidget {
  final String imagePath;
  final String imagePathHover;
  final double height;
  final bool isBlurred;

  const TeamMemberImage({
    super.key,
    required this.imagePath,
    required this.height,
    this.isBlurred = false,
    required this.imagePathHover,
  });

  @override
  State<TeamMemberImage> createState() => _TeamMemberImageState();
}

class _TeamMemberImageState extends State<TeamMemberImage> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base image (unblurred, always visible)
            Image.network(widget.imagePath, fit: BoxFit.cover),
            // Hover image with opacity transition
            AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              opacity: _isHovered ? 1.0 : 0.0,
              child: Image.network(widget.imagePathHover, fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }
}
