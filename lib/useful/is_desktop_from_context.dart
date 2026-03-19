import 'package:flutter/material.dart';

bool isDesktopFromContext(BuildContext context) =>
    MediaQuery.of(context).size.width >= 1440;
