import 'package:flutter/material.dart';

class PatoghCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const PatoghCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });
}
