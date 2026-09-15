import 'package:flutter/material.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      icon: Icons.sports_esports_rounded,
      title: 'بازی',
      subtitle: 'بازی‌های یخ‌شکن و فعالیت‌های کوتاه گروهی اینجا قرار می‌گیرند.',
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PlaceholderPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 74, color: const Color(0xFFFF8A2A)),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFB7B7B7), height: 1.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
