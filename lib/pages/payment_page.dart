import 'package:flutter/material.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/pages/payment_success_page.dart';

class PaymentPage extends StatelessWidget {
  final PatoghEvent event;

  const PaymentPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پرداخت و رزرو'),
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
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'خلاصه رزرو',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _line('پاتوق', event.title),
                    _line('تاریخ', event.date),
                    _line('ساعت', event.time),
                    _line('محدوده', event.area),
                    const Divider(height: 28),
                    _line(
                      'مبلغ قابل پرداخت',
                      '${_money(event.price)} تومان',
                      strong: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'پرداخت آزمایشی نسخه اولیه',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'در نسخه نهایی این بخش به درگاه پرداخت واقعی متصل می‌شود. فعلاً پرداخت شبیه‌سازی می‌شود.',
                      style: TextStyle(
                        color: Color(0xFFBBBBBB),
                        height: 1.7,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => PaymentSuccessPage(event: event),
                    ),
                  );
                },
                icon: const Icon(Icons.lock_rounded),
                label: const Text(
                  'پرداخت و ثبت رزرو',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A2A),
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String title, String value, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Text(title, style: const TextStyle(color: Color(0xFFAAAAAA))),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
                color: strong ? const Color(0xFFFF8A2A) : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _money(int value) {
    final raw = value.toString();
    final result = <String>[];
    for (var i = 0; i < raw.length; i++) {
      result.add(raw[i]);
      final remaining = raw.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) result.add(',');
    }
    return result.join();
  }
}
