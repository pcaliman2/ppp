import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideFrom; // e.g. Offset(0, 0.04) = subtle slide up

  const ScrollFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.slideFrom = const Offset(0, 0.04),
  });

  @override
  State<ScrollFadeIn> createState() => _ScrollFadeInState();
}

class _ScrollFadeInState extends State<ScrollFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final GlobalKey _key = GlobalKey();
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: widget.slideFrom,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Check after first frame if already visible
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (_triggered || !mounted) return;

    final renderObject = _key.currentContext?.findRenderObject();
    if (renderObject == null) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    final scrollable = Scrollable.of(_key.currentContext!);
    final position = scrollable.position;

    final revealedOffset = viewport.getOffsetToReveal(renderObject, 0.0);
    final isVisible =
        revealedOffset.offset <
        position.pixels + position.viewportDimension * 0.92;

    if (isVisible) {
      _trigger();
    }
  }

  void _trigger() {
    if (_triggered) return;
    _triggered = true;
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        _checkVisibility();
        return false;
      },
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SizedBox(key: _key, child: widget.child),
        ),
      ),
    );
  }
}
