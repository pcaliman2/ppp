import 'package:flutter/material.dart';
import 'package:owa_flutter/widgets/go_to_qntmbody_instagram.dart';
import 'package:owa_flutter/widgets/headline.dart';
import 'package:owa_flutter/widgets/hover_image_widget.dart';

class OWAFollowUsSection extends StatelessWidget {
  const OWAFollowUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: 387.46,
            height: 66,
            alignment: Alignment.center,
            child: Headline(
              child: Text(
                'We are on a mission to explore integrative wellbeing and\ncontinuously evolve our spaces as centers of restoration,\nconnection, and growth.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Arbeit',
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.normal,
                  fontSize: 15,
                  height: 22 / 15,
                  letterSpacing: 0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 165.55,
        ), // Espacio entre el box y el siguiente elemento
      ],
    );
  }

  Widget _buildInstagramImage(String imagePath, {bool isDesktop = true}) {
    return GestureDetector(
      onTap: goToQNTMBodyInstagram,
      child: HoverImageWidget(imagePath: imagePath, isDesktop: isDesktop),
    );
  }
}
