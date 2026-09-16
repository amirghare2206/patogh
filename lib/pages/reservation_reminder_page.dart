import 'package:flutter/material.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/state/app_state.dart';

class ReservationReminderPage extends StatelessWidget {
  final PatoghEvent event;

  const ReservationReminderPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final waitlist = appState.waitlistIds.contains(event.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('یادآوری پاتوق'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
            children: [
              Container(
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(colors: event.gradient),
                ),
                child: Icon(event.icon, size: 88, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Container(
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: waitlist
                      ? const Color(0xFF4A3218)
                      : const Color(0xFFC7CAD0),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  waitlist ? 'در لیست انتظار' : 'رزرو تأیید شده',
                  style: TextStyle(
                    color: waitlist
                        ? const Color(0xFFFFC26B)
                        : const Color(0xFF242424),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF214A5F)),
                ),
                child: Column(
                  children: [
                    _row(
                      Icons.location_on_outlined,
                      'محل برگزاری',
                      'محدوده برگزاری: ${event.area}\n${event.exactLocationNote}',
                    ),
                    const Divider(height: 28, color: Color(0xFF263B45)),
                    _row(
                      Icons.calendar_month_rounded,
                      'تاریخ پاتوق',
                      '${event.date}، ساعت ${event.time}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'یادآوری‌های پاتوق',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                '• گروه‌بندی‌ها به‌صورت سیستمی انجام می‌شود.\n\n• مبلغ پاتوق بابت هماهنگی و خدمات اجرایی است و سفارش رستوران را شامل نمی‌شود.\n\n• در بعضی محل‌ها هزینه سفارش هر نفر جداگانه محاسبه می‌شود.\n\n• هنگام مراجعه، کد پاتوق خود را به میزبان اعلام کنید.',
                style: TextStyle(color: Color(0xFFDADADA), height: 1.8),
              ),
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: () async {
                  await appState.cancelReservation(event.id);
                  if (context.mounted) Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close_rounded),
                label: const Text('لغو / خروج از رزرو'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF9B9B),
                  side: const BorderSide(color: Color(0xFF6A3333)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 29),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(color: Color(0xFFD3D3D3), height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
