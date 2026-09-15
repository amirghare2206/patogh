import 'package:flutter/material.dart';

class PatoghEvent {
  final String id;
  final String categoryId;
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String area;
  final String exactLocationNote;
  final int price;
  final int capacity;
  final int reserved;
  final bool womenOnly;
  final bool full;
  final String description;
  final List<String> participants;
  final List<Color> gradient;
  final IconData icon;

  const PatoghEvent({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.area,
    required this.exactLocationNote,
    required this.price,
    required this.capacity,
    required this.reserved,
    required this.womenOnly,
    required this.full,
    required this.description,
    required this.participants,
    required this.gradient,
    required this.icon,
  });

  int get seatsLeft => capacity - reserved;
}
