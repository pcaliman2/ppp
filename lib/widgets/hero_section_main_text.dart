import 'dart:async';

import 'package:flutter/material.dart';

class HeroSectionMainText extends StatefulWidget {
  const HeroSectionMainText({super.key});

  @override
  State<HeroSectionMainText> createState() => _HeroSectionMainTextState();
}

class _HeroSectionMainTextState extends State<HeroSectionMainText>
    with TickerProviderStateMixin {
  late AnimationController _wheelController;
  late Timer _wordTimer;

  int _currentWordIndex = 0;

  // List of words that will rotate (excluding "ONE WITH")
  final List<String> _rotatingWords = [
    'ALL',
    'COMMUNITY',
    'CENTER',
    'JOY',
    'MIND',
    'BODY',
    'SPIRIT',
  ];

  @override
  void initState() {
    super.initState();

    // Animation controller for the wheel rotation effect
    _wheelController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Timer to change words every 3 seconds
    _wordTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _animateToNextWord();
    });
  }

  void _animateToNextWord() {
    _wheelController.forward().then((_) {
      setState(() {
        _currentWordIndex = (_currentWordIndex + 1) % _rotatingWords.length;
      });
      _wheelController.reset();
    });
  }

  @override
  void dispose() {
    _wheelController.dispose();
    _wordTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: const Text(
        'OWA° iis Mexico City´s first wellness club, bringing together the essential pillars of human wellbeing in one place.',
        style: TextStyle(
          fontFamily: 'Basier Square Mono',
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w400,
          height: 1.6,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
