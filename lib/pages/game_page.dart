import 'package:flutter/material.dart';
import 'package:patogh/pages/game_detail_page.dart';
import 'package:patogh/theme/patogh_theme.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final games = <({
      String title,
      String subtitle,
      IconData icon,
      Color firstColor,
      Color secondColor,
      String badge,
    })>[
      (
        title: 'شطرنج آنلاین',
        subtitle: 'رقابت دونفره، اتاق خصوصی و دعوت از هم‌پاتوقی‌ها',
        icon: Icons.grid_on_rounded,
        firstColor: const Color(0xFF6C5CE7),
        secondColor: const Color(0xFF4834D4),
        badge: 'دونفره',
      ),
      (
        title: 'دوز',
        subtitle: 'یک رقابت سریع و ساده با دوستان پاتوق',
        icon: Icons.close_rounded,
        firstColor: const Color(0xFFFF7675),
        secondColor: const Color(0xFFE84393),
        badge: 'سریع',
      ),
      (
        title: 'مار و پله',
        subtitle: 'بازی دورهمی چندنفره با اتاق‌های دوستانه',
        icon: Icons.casino_rounded,
        firstColor: const Color(0xFF00B894),
        secondColor: const Color(0xFF00CEC9),
        badge: 'چندنفره',
      ),
      (
        title: 'تخته نرد',
        subtitle: 'رقابت کلاسیک آنلاین با دوستان و کاربران پاتوق',
        icon: Icons.blur_circular_rounded,
        firstColor: const Color(0xFFFDCB6E),
        secondColor: const Color(0xFFE17055),
        badge: 'دونفره',
      ),
    ];

    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: PatoghTheme.brandGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.sports_esports_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'بازی‌های پاتوق',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'بازی کن، رقابت کن و هم‌پاتوقی پیدا کن',
                      style: TextStyle(
                        color: PatoghTheme.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF7C4DFF),
                  Color(0xFFFF5F8F),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C4DFF).withAlpha(55),
                  blurRadius: 22,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎮 رقابت آنلاین',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'نسخه V14 برای اتاق بازی، دعوت دوستان و رقابت آنلاین آماده می‌شود.',
                        style: TextStyle(
                          color: Colors.white,
                          height: 1.5,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'انتخاب بازی',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: games.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, index) {
              final game = games[index];

              return InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GameDetailPage(
                        title: game.title,
                        icon: game.icon,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        game.firstColor,
                        game.secondColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: game.firstColor.withAlpha(42),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(35),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              game.icon,
                              color: Colors.white,
                              size: 27,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(38),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              game.badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        game.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        game.subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Text(
                            'ورود به بازی',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}