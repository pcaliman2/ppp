import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> customLaunchURL(String urlString) async {
  final Uri url = Uri.parse(urlString);
  try {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  } catch (e) {
    debugPrint('Error launching URL: $e');
  }
}
