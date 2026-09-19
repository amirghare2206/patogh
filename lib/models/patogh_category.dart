import 'package:flutter/material.dart';

class PatoghCategory {
  final String id;
  final String title;
  final String subtitle;
  final int iconCodePoint;
  final int colorValue;
  final int sortOrder;
  final bool isActive;

  const PatoghCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconCodePoint,
    required this.colorValue,
    this.sortOrder = 0,
    this.isActive = true,
  });

  IconData get icon {
    switch (id) {
      case 'intro':
        return Icons.groups_rounded;
      case 'talk':
        return Icons.forum_rounded;
      case 'game':
        return Icons.sports_esports_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'learn':
        return Icons.school_rounded;
      case 'travel':
        return Icons.travel_explore_rounded;
      case 'think':
        return Icons.lightbulb_rounded;
      case 'sport':
        return Icons.sports_basketball_rounded;
      case 'story':
        return Icons.menu_book_rounded;
      case 'empathy':
        return Icons.favorite_rounded;
      case 'volunteer':
        return Icons.volunteer_activism_rounded;
      case 'companion':
        return Icons.route_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color get accent => Color(colorValue);

  PatoghCategory copyWith({
    String? title,
    String? subtitle,
    int? sortOrder,
    bool? isActive,
  }) {
    return PatoghCategory(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'iconCodePoint': iconCodePoint,
    'colorValue': colorValue,
    'sortOrder': sortOrder,
    'isActive': isActive,
  };

  factory PatoghCategory.fromJson(Map<String, dynamic> map) {
    return PatoghCategory(
      id: '${map['id']}',
      title: (map['title'] as String?) ?? 'دسته جدید',
      subtitle: (map['subtitle'] as String?) ?? '',
      iconCodePoint:
          (map['iconCodePoint'] as num?)?.toInt() ??
          Icons.category_rounded.codePoint,
      colorValue: (map['colorValue'] as num?)?.toInt() ?? 0xFF5B9DFF,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: (map['isActive'] as bool?) ?? true,
    );
  }
}
