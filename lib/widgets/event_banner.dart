import 'package:flutter/material.dart';
import 'package:patogh/models/patogh_event.dart';

class EventBanner extends StatelessWidget {
  final PatoghEvent event;
  final VoidCallback onTap;
  final bool compact;

  const EventBanner({
    super.key,
    required this.event,
    required this.onTap,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final height = compact ? 185.0 : 220.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: height,
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
                  Positioned(
                    right: 22,
                    top: 22,
                    child: Icon(
                      event.icon,
                      color: Colors.white.withValues(alpha: 0.94),
                      size: compact ? 64 : 78,
                    ),
                  ),
                  Positioned(
                    left: 22,
                    bottom: 18,
                    child: Row(
                      children: List.generate(4, (index) {
                        return Transform.translate(
                          offset: Offset(index * 8.0, 0),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: [
                                const Color(0xFFB96E52),
                                const Color(0xFF566E85),
                                const Color(0xFF806273),
                                const Color(0xFF6A7657),
                              ][index],
                              child: const Icon(
                                Icons.person_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Positioned(
                    right: 22,
                    bottom: 18,
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
                        event.full
                            ? 'تکمیل ظرفیت'
                            : '${event.seatsLeft} صندلی باقی مانده',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
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
                fontSize: compact ? 19 : 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${event.date}، ساعت ${event.time}',
              style: const TextStyle(color: Color(0xFFD9D9D9), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
