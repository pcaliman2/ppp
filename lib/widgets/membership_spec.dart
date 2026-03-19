import 'package:flutter/material.dart';

class MembershipSpec {
  final String? number;
  final String title;
  final String price;
  final String imagePath;
  final String mainDescription;
  final List<String>? benefits;
  final double? borderRadiusValue;
  final VoidCallback onTap;

  const MembershipSpec({
    this.number,
    required this.title,
    required this.price,
    required this.imagePath,
    required this.mainDescription,
    this.benefits,
    this.borderRadiusValue,
    required this.onTap,
  });
}
