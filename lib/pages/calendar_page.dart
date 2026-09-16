import 'package:flutter/material.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final days = List.generate(35, (index) => index < 3 ? '' : '${index - 2}');

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
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final hasEvent = index == 9 || index == 14 || index == 22;
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hasEvent
                          ? const Color(0x33FF8A2A)
                          : const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(10),
                      border: hasEvent
                          ? Border.all(color: const Color(0xFFFF8A2A))
                          : null,
                    ),
                    child: Text(days[index]),
                  );
                },
              ),
              const SizedBox(height: 20),
              const _Legend(Color(0xFF9C66FF), 'پاتوق‌های آینده'),
              const _Legend(Color(0xFF4FC48B), 'رزروهای تأیید شده'),
              const _Legend(Color(0xFFFF9A3C), 'در انتظار پرداخت'),
              const _Legend(Color(0xFF4D9BE8), 'پاتوق‌های برگزارشده'),
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

  const _Legend(this.color, this.label);

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
