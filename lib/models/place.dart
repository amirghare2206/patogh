import 'package:flutter/material.dart';

class Place {
  final String title;
  final String category;
  final String area;
  final String rating;
  final String distance;
  final String description;
  final IconData icon;
  final Color background;
  final Color foreground;

  const Place({
    required this.title,
    required this.category,
    required this.area,
    required this.rating,
    required this.distance,
    required this.description,
    required this.icon,
    required this.background,
    required this.foreground,
  });
}
