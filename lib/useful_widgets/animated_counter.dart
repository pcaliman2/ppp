import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnimatedCounter extends StatefulWidget {
  final String targetValue;
  final TextStyle style;
  final Duration duration;
  final Curve curve;
  final int intermediateSteps;
  final Key? visibilityKey; // Add this for VisibilityDetector

  const AnimatedCounter({
    super.key,
    required this.targetValue,
    required this.style,
    this.duration = const Duration(milliseconds: 3000),
    this.curve = Curves.easeOut,
    this.intermediateSteps = 100,
    this.visibilityKey,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _targetNumber;
  late String _prefix;
  late String _suffix;
  late String _multiplierSuffix;
  bool _hasAnimated = false;
  late int _decimalPlaces;

  @override
  void initState() {
    super.initState();
    _parseTargetValue();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 0,
      end: _targetNumber,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Don't auto-start animation
  }

  void _startAnimation() {
    if (!_hasAnimated) {
      _hasAnimated = true;
      _controller.forward();
    }
  }

  void _parseTargetValue() {
    String value = widget.targetValue.trim();
    _prefix = '';
    _suffix = '';
    _multiplierSuffix = '';

    // Extract prefix
    if (value.startsWith('\$') ||
        value.startsWith('+') ||
        value.startsWith('-')) {
      _prefix = value[0];
      value = value.substring(1).trim();
    }

    // Updated regex to handle commas and optional whitespace before multiplier
    final numMatch = RegExp(
      r'^([\d.,]+)\s*([BMKH]?)(.*)$',
      caseSensitive: false,
    ).firstMatch(value);

    if (numMatch != null) {
      String numberStr = numMatch.group(1)!;

      // Remove commas before parsing
      String cleanNumber = numberStr.replaceAll(',', '');

      _targetNumber = double.tryParse(cleanNumber) ?? 0;
      _multiplierSuffix = (numMatch.group(2)?.trim().toUpperCase()) ?? '';
      _suffix = numMatch.group(3)?.trim() ?? '';

      // Check decimal places from the clean number
      if (cleanNumber.contains('.')) {
        _decimalPlaces = cleanNumber.split('.')[1].length;
      } else {
        _decimalPlaces = 0;
      }
    } else {
      _targetNumber = 0;
      _decimalPlaces = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    bool isAtTarget = value >= _targetNumber * 0.999;
    bool targetIsInteger = _targetNumber % 1 == 0;

    String formattedValue;

    if (isAtTarget && targetIsInteger) {
      formattedValue = value.round().toString();
    } else if (_multiplierSuffix.isNotEmpty) {
      if (value < 0.01) {
        formattedValue = value.toStringAsFixed(3);
      } else if (value < 0.1) {
        formattedValue = value.toStringAsFixed(2);
      } else if (value < 1) {
        formattedValue = value.toStringAsFixed(2);
      } else if (value < 10) {
        formattedValue = value.toStringAsFixed(2);
      } else {
        formattedValue = value.toStringAsFixed(1);
      }
    } else {
      formattedValue = value.toStringAsFixed(_decimalPlaces);
    }

    // Add commas for thousands separator if original had commas
    if (widget.targetValue.contains(',')) {
      formattedValue = _addThousandsSeparator(formattedValue);
    }

    return formattedValue;
  }

  String _addThousandsSeparator(String number) {
    // Split into integer and decimal parts
    List<String> parts = number.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Add commas to integer part
    String result = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = ',$result';
        count = 0;
      }
      result = integerPart[i] + result;
      count++;
    }

    return result + decimalPart;
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key:
          widget.visibilityKey ?? Key('animated_counter_${widget.targetValue}'),
      onVisibilityChanged: (VisibilityInfo info) {
        // Trigger animation when at least 10% of the widget is visible
        if (info.visibleFraction > 0.1 && !_hasAnimated) {
          _startAnimation();
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Text(
            '$_prefix${_formatNumber(_animation.value)}$_multiplierSuffix$_suffix',
            style: widget.style,
          );
        },
      ),
    );
  }
}
