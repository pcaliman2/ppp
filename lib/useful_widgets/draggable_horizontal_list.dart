import 'package:flutter/material.dart';

class SmoothDraggableHorizontalList extends StatefulWidget {
  final List<Widget> items;
  final double itemWidth;
  final ScrollController? externalController; // Add this

  const SmoothDraggableHorizontalList({
    super.key,
    required this.items,
    this.itemWidth = 400,
    this.externalController, // Add this
  });

  @override
  State<SmoothDraggableHorizontalList> createState() =>
      _SmoothDraggableHorizontalListState();
}

class _SmoothDraggableHorizontalListState
    extends State<SmoothDraggableHorizontalList>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  double _velocity = 0;
  AnimationController? _animationController;
  double _currentScroll = 0;

  @override
  void initState() {
    super.initState();
    // Use external controller if provided, otherwise create new one
    _scrollController = widget.externalController ?? ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _currentScroll = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    // Only dispose if we created the controller internally
    if (widget.externalController == null) {
      _scrollController.dispose();
    }
    _animationController?.dispose();
    super.dispose();
  }

  // Rest of the code remains the same...
  void _handleDragEnd(DragEndDetails details) {
    _velocity = details.primaryVelocity ?? 0;

    _animationController?.dispose();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final double start = _scrollController.offset;
    final double end = start - _velocity * 0.3;

    _animationController!.addListener(() {
      final value = Curves.easeOut.transform(_animationController!.value);
      _scrollController.jumpTo(start + (end - start) * value);
    });

    _animationController!.forward();
  }

  double _calculateOpacity(int index) {
    final itemPosition = index * widget.itemWidth;
    final scrollOffset = _currentScroll;

    if (itemPosition >= scrollOffset &&
        itemPosition < scrollOffset + widget.itemWidth) {
      return 1.0;
    }

    return 0.4;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        _scrollController.jumpTo(_scrollController.offset - details.delta.dx);
      },
      onHorizontalDragEnd: _handleDragEnd,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(widget.items.length, (index) {
            return AnimatedOpacity(
              opacity: _calculateOpacity(index),
              duration: const Duration(milliseconds: 200),
              child: widget.items[index],
            );
          }),
        ),
      ),
    );
  }
}
