import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final items = <(String, String, IconData)>[
            (
              'پیشنهاد پاتوق',
              'یک پاتوق جدید بر اساس علایق شما اضافه شد.',
              Icons.auto_awesome_rounded,
            ),
            if (appState.circleMembers.any(
              (item) => item.accepted && item.notifyOnEventJoin,
            ))
              (
                'حلقه من',
                'یکی از اعضای حلقه‌ات اجازه داده هنگام رزرو رویدادهای منتخب به تو خبر بدهیم.',
                Icons.diversity_1_rounded,
              ),
            if (appState.reservedIds.isNotEmpty)
              (
                'رزرو تأیید شد',
                'یکی از پاتوق‌های شما ثبت شده.',
                Icons.event_available_rounded,
              ),
            if (appState.waitlistIds.isNotEmpty)
              (
                'لیست انتظار',
                'در صورت آزاد شدن ظرفیت اطلاع می‌دهیم.',
                Icons.hourglass_bottom_rounded,
              ),
          ];

          return ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const Text(
                'اعلان‌ها',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              ...items.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: const Color(0xFF171717),
                    borderRadius: BorderRadius.circular(20),
                    child: ListTile(
                      leading: Icon(item.$3, color: PatoghTheme.orange),
                      title: Text(item.$1),
                      subtitle: Text(item.$2),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
