import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/compute_responsive_factor.dart';
import 'package:owa_flutter/widgets/headline.dart';
import 'package:owa_flutter/widgets/hover_image_widget.dart';

class OWAFollowUsSectionMobile extends StatelessWidget {
  const OWAFollowUsSectionMobile({super.key});

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

  Widget _buildInstagramImage(
    BuildContext context,
    String imagePath, {
    required VoidCallback onTap,
    bool isDesktop = true,
  }) {
    double responsivefactor = computeScreenRatio(context) * 0.42;
    return GestureDetector(
      onTap: onTap,
      child: HoverImageWidget(imagePath: imagePath, isDesktop: false),
      // Container(
      //   width: 180, // SizeConfig.w(190), //* (responsivefactor),
      //   height: 180, // SizeConfig.h(190), //* (responsivefactor),
      //   decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(
      //       SizeConfig.w(9.99),
      //     ), // Exact border radius
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black.withOpacity(0.1),
      //         blurRadius: 8,
      //         offset: const Offset(0, 4),
      //       ),
      //     ],
      //   ),
      //   child: ClipRRect(
      //     borderRadius: BorderRadius.circular(SizeConfig.w(9.99)),
      //     child: Image.asset(
      //       imagePath,
      //       fit: BoxFit.cover,
      //       errorBuilder: (context, error, stackTrace) {
      //         // Fallback placeholder when image is not found
      //         return Container(
      //           color: const Color(0xFF2C2C2C),
      //           child: Center(
      //             child: Column(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //                 Icon(
      //                   Icons.photo,
      //                   color: Colors.white.withOpacity(0.6),
      //                   size: SizeConfig.w(40),
      //                 ),
      //                 SizedBox(height: SizeConfig.h(8)),
      //                 Text(
      //                   'Image',
      //                   style: TextStyle(
      //                     color: Colors.white.withOpacity(0.6),
      //                     fontSize: SizeConfig.t(12),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         );
      //       },
      //     ),
      //   ),
      // ),
    );
  }
}
