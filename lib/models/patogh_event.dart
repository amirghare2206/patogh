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

  factory PatoghEvent.fromMap(Map<String, dynamic> map) {
    final category = (map['category_id'] as String?) ?? 'intro';
    final style = _styleFor(category);

    return PatoghEvent(
      id: '${map['id']}',
      categoryId: category,
      title: (map['title'] as String?) ?? 'پاتوق',
      subtitle: (map['subtitle'] as String?) ?? '',
      date: (map['date_label'] as String?) ?? '',
      time: (map['time_label'] as String?) ?? '',
      area: (map['area'] as String?) ?? 'مشهد',
      exactLocationNote: (map['exact_location_note'] as String?) ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      capacity: (map['capacity'] as num?)?.toInt() ?? 0,
      reserved: (map['reserved_count'] as num?)?.toInt() ?? 0,
      womenOnly: (map['women_only'] as bool?) ?? false,
      discounted: (map['discounted'] as bool?) ?? false,
      discountPercent: (map['discount_percent'] as num?)?.toInt() ?? 0,
      description: (map['description'] as String?) ?? '',
      participants: List<String>.from(
        (map['participants'] as List?) ?? const <String>[],
      ),
      tags: List<String>.from((map['tags'] as List?) ?? const <String>[]),
      gradient: style.$1,
      icon: style.$2,
    );
  }

  Map<String, dynamic> toRemoteMap({String? hostId}) {
    return {
      'id': id,
      'host_id': hostId,
      'category_id': categoryId,
      'title': title,
      'subtitle': subtitle,
      'date_label': date,
      'time_label': time,
      'area': area,
      'exact_location_note': exactLocationNote,
      'price': price,
      'capacity': capacity,
      'reserved_count': reserved,
      'women_only': womenOnly,
      'discounted': discounted,
      'discount_percent': discountPercent,
      'description': description,
      'participants': participants,
      'tags': tags,
      'published': true,
    };
  }

  static (List<Color>, IconData) _styleFor(String category) {
    switch (category) {
      case 'talk':
        return (
          const [Color(0xFF775B4E), Color(0xFF2B2420)],
          Icons.forum_rounded,
        );
      case 'game':
        return (
          const [Color(0xFF334C7A), Color(0xFF161A24)],
          Icons.sports_esports_rounded,
        );
      case 'work':
        return (
          const [Color(0xFF295B6A), Color(0xFF13242A)],
          Icons.work_rounded,
        );
      case 'think':
        return (
          const [Color(0xFF6E4A31), Color(0xFF241B16)],
          Icons.auto_stories_rounded,
        );
      case 'sport':
        return (
          const [Color(0xFF5D3F20), Color(0xFF22180F)],
          Icons.sports_basketball_rounded,
        );
      case 'learn':
        return (
          const [Color(0xFF754C2C), Color(0xFF2A1D15)],
          Icons.palette_rounded,
        );
      default:
        return (
          const [Color(0xFF486B52), Color(0xFF1B1B1B)],
          Icons.groups_rounded,
        );
    }
  }
}
