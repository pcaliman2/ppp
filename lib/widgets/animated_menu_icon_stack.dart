import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;

class AnimatedMenuIconStack extends StatelessWidget {
  const AnimatedMenuIconStack({super.key, required this.isExpanded});

  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isExpanded ? colors.backgroundColor : colors.onHoverButtonColor,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// isExpanded ? Fill with colors.backgroundColor : Fill with colors.onHoverButtonColor
          SvgPicture.asset(
            'assets/icons/circle.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          isExpanded
              ? SvgPicture.asset(
                'assets/icons/remove_icon.svg',
                width: 1,
                height: 1,
              )
              : SvgPicture.asset(
                'assets/icons/add_icon.svg',
                width: 7,
                height: 7,
              ),
        ],
      ),
    );
  }
}
