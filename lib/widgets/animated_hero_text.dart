import 'dart:async';
import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/size_config.dart';

class AnimatedHeroText extends StatefulWidget {
  const AnimatedHeroText({super.key});

  @override
  State<AnimatedHeroText> createState() => _AnimatedHeroTextState();
}

class _AnimatedHeroTextState extends State<AnimatedHeroText>
    with TickerProviderStateMixin {
  late AnimationController _wheelController;
  late Animation<double> _wheelAnimation;
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

  // Consistent text style for all text elements
  static const TextStyle _heroTextStyle = TextStyle(
    fontFamily: 'Basier Square Mono',
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.6, // 160% line height
    letterSpacing: 20, // 100% of 20px = 20px
  );

  @override
  void initState() {
    super.initState();

    // Animation controller for the wheel rotation effect
    _wheelController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Tween for smooth vertical translation
    _wheelAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _wheelController, curve: Curves.easeInOutCubic),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Static "ONE WITH" text
        Padding(
          padding: EdgeInsets.only(left: SizeConfig.w(20.0)),
          child: const Text(
            '     ONE WITH ',
            style: _heroTextStyle,
            textAlign: TextAlign.center,
          ),
        ),

        // Animated rotating word section
        SizedBox(
          height:
              32, // Adjusted height based on 20px font size and 160% line height
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _wheelAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Current word (sliding up and fading out)
                    Transform.translate(
                      offset: Offset(0, -32 * _wheelAnimation.value),
                      child: Opacity(
                        opacity: 1.0 - _wheelAnimation.value,
                        child: Text(
                          _rotatingWords[_currentWordIndex],
                          style: _heroTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Next word (sliding up and fading in)
                    Transform.translate(
                      offset: Offset(0, 32 * (1.0 - _wheelAnimation.value)),
                      child: Opacity(
                        opacity: _wheelAnimation.value,
                        child: Text(
                          _rotatingWords[(_currentWordIndex + 1) %
                              _rotatingWords.length],
                          style: _heroTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Additional words for the wheel effect (background)
                    ...List.generate(3, (index) {
                      final wordIndex =
                          (_currentWordIndex + index + 2) %
                          _rotatingWords.length;
                      return Transform.translate(
                        offset: Offset(
                          0,
                          64 + (index * 32) - (32 * _wheelAnimation.value),
                        ),
                        child: Opacity(
                          opacity: 0.3 - (index * 0.1),
                          child: Text(
                            _rotatingWords[wordIndex],
                            style: _heroTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),

                    // Previous words for the wheel effect (above)
                    ...List.generate(2, (index) {
                      final wordIndex =
                          (_currentWordIndex - index - 1) %
                          _rotatingWords.length;
                      return Transform.translate(
                        offset: Offset(
                          0,
                          -64 - (index * 32) - (32 * _wheelAnimation.value),
                        ),
                        child: Opacity(
                          opacity: 0.2 - (index * 0.1),
                          child: Text(
                            _rotatingWords[wordIndex < 0
                                ? _rotatingWords.length + wordIndex
                                : wordIndex],
                            style: _heroTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
