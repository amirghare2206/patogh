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
  final bool discounted;
  final int discountPercent;
  final String description;
  final List<String> participants;
  final List<String> tags;
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
    required this.discounted,
    required this.discountPercent,
    required this.description,
    required this.participants,
    required this.tags,
    required this.gradient,
    required this.icon,
  });

  int get seatsLeft => capacity - reserved;
  bool get isFull => seatsLeft <= 0;
  int get finalPrice =>
      discounted ? (price * (100 - discountPercent) ~/ 100) : price;
}
