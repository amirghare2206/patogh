import 'package:flutter/material.dart';
import 'package:patogh/pages/chat_page.dart';
import 'package:patogh/pages/communities_page.dart';
import 'package:patogh/pages/notifications_page.dart';
import 'package:patogh/pages/stories_page.dart';
import 'package:patogh/pages/timeline_page.dart';
import 'package:patogh/theme/patogh_theme.dart';

class SocialHubPage extends StatefulWidget {
  const SocialHubPage({super.key});

  @override
  State<SocialHubPage> createState() => _SocialHubPageState();
}

class _SocialHubPageState extends State<SocialHubPage> {
  int selected = 0;

  final pages = const [
    StoriesPage(),
    TimelinePage(),
    ChatPage(),
    CommunitiesPage(),
    NotificationsPage(),
  ];

  final titles = const [
    'استوری',
    'تایم‌لاین',
    'چت',
    'گروه‌ها',
    'اعلان‌ها',
  ];

  final subtitles = const [
    'لحظه‌های هم‌پاتوقی‌ها',
    'تجربه‌ها و پست‌های تازه',
    'گفت‌وگوهای خصوصی',
    'گروه‌ها و کانال‌ها',
    'اتفاق‌های مهم برای تو',
  ];

  final icons = const [
    Icons.auto_stories_rounded,
    Icons.dynamic_feed_rounded,
    Icons.chat_bubble_rounded,
    Icons.groups_rounded,
    Icons.notifications_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _header(),
          _sectionSelector(),
          const SizedBox(height: 6),
          Expanded(
            child: IndexedStack(
              index: selected,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: PatoghTheme.brandGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: PatoghTheme.purple.withAlpha(45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.diversity_3_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اجتماع پاتوق',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitles[selected],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icons[selected],
              color: Colors.white,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionSelector() {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: pages.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final active = selected == index;

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                selected = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                gradient: active ? PatoghTheme.brandGradient : null,
                color: active ? null : PatoghTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active
                      ? Colors.transparent
                      : PatoghTheme.surface2,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: PatoghTheme.purple.withAlpha(35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    icons[index],
                    size: 19,
                    color: active
                        ? Colors.white
                        : PatoghTheme.muted,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    titles[index],
                    style: TextStyle(
                      color: active
                          ? Colors.white
                          : Colors.white,
                      fontSize: 11,
                      fontWeight: active
                          ? FontWeight.w900
                          : FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}