import 'package:flutter/material.dart';
import 'package:owa_flutter/owa_app.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  // Remove the # from URLs in Flutter Web
  usePathUrlStrategy();

  runApp(const OWAApp());
}
