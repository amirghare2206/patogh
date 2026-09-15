import 'package:flutter/material.dart';
import 'package:patogh/models/patogh_category.dart';

class CategoryCard extends StatelessWidget {
  final PatoghCategory category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: category.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(category.icon, color: category.accent, size: 32),
              ),
              const SizedBox(height: 9),
              Text(
                category.title,
                style: const TextStyle(
                  color: Color(0xFF262626),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                category.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF616161),
                  fontSize: 9,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
