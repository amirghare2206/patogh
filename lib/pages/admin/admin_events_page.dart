import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class AdminEventsPage extends StatelessWidget {
  const AdminEventsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت رویدادها'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: appState.events.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final event = appState.events[index];
          return Material(
            color: const Color(0xFF181818),
            borderRadius: BorderRadius.circular(18),
            child: ListTile(
              leading: Icon(event.icon, color: PatoghTheme.orange),
              title: Text(event.title),
              subtitle: Text(
                '${event.capacity} نفر • ${event.finalPrice} تومان',
              ),
              trailing: PopupMenuButton<String>(
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'approve', child: Text('تأیید انتشار')),
                  PopupMenuItem(value: 'pause', child: Text('توقف رزرو')),
                  PopupMenuItem(value: 'cancel', child: Text('لغو رویداد')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
