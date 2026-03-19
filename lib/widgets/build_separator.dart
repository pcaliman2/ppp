import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/widgets/fade_in_widget.dart';

Widget buildSeparator() => HorizontalFadeInWidget(
  child: Container(
    width: double.infinity,
    height: SizeConfig.h(1),
    color: const Color(0xFF656565),
  ),
);
