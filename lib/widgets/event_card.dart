import 'package:flutter/material.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class EventCard extends StatelessWidget {
  final PatoghEvent event;
  final VoidCallback onTap;
  final bool compact;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final favorite = appState.favoriteIds.contains(event.id);
        final match = appState.matchScore(event.tags);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: compact ? 170 : 215,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: event.gradient,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          event.icon,
                          color: Colors.white.withAlpha(230),
                          size: compact ? 68 : 84,
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: IconButton.filledTonal(
                          onPressed: () => appState.toggleFavorite(event.id),
                          icon: Icon(
                            favorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: favorite ? Colors.redAccent : Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 14,
                        top: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xCC000000),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'سازگاری $match٪',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xCC000000),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event.isFull
                                ? 'تکمیل ظرفیت'
                                : '${event.seatsLeft} صندلی باقی مانده',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ),
                      if (event.discounted)
                        Positioned(
                          left: 60,
                          top: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: PatoghTheme.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${event.discountPercent}٪ تخفیف',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: compact ? 18 : 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.date}، ساعت ${event.time}',
                  style: const TextStyle(
                    color: Color(0xFFD0D0D0),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
