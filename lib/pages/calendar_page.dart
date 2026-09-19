import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reserved = appState.events
        .where((event) => appState.reservedIds.contains(event.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقویم شخصی'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const Text(
                'تیر ۱۴۰۵',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemCount: 35,
                itemBuilder: (context, index) {
                  final label = index < 3 ? '' : '${index - 2}';
                  final highlighted =
                      reserved.isNotEmpty && (index == 9 || index == 14);
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: highlighted
                          ? PatoghTheme.orange.withAlpha(45)
                          : const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(10),
                      border: highlighted
                          ? Border.all(color: PatoghTheme.orange)
                          : null,
                    ),
                    child: Text(label),
                  );
                },
              ),
              const SizedBox(height: 22),
              const _Legend(color: Color(0xFF9C66FF), label: 'پاتوق‌های آینده'),
              const _Legend(
                color: Color(0xFF4FC48B),
                label: 'رزروهای تأییدشده',
              ),
              const _Legend(
                color: Color(0xFFFF9A3C),
                label: 'در انتظار پرداخت',
              ),
              const _Legend(
                color: Color(0xFF4D9BE8),
                label: 'پاتوق‌های برگزارشده',
              ),
              if (reserved.isNotEmpty) ...[
                const SizedBox(height: 22),
                const Text(
                  'برنامه‌های من',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                ...reserved.map(
                  (event) => Card(
                    child: ListTile(
                      leading: Icon(event.icon),
                      title: Text(event.title),
                      subtitle: Text('${event.date} • ${event.time}'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(radius: 6, backgroundColor: color),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
