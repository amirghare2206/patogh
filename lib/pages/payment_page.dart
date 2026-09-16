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
                  children: [
                    _line('پاتوق', event.title),
                    _line('تاریخ', event.date),
                    _line('مبلغ', '${event.finalPrice} تومان'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'پرداخت در این نسخه شبیه‌سازی می‌شود. اتصال به درگاه واقعی در مرحله اتصال سرویس انجام می‌شود.',
                style: TextStyle(color: Color(0xFFBBBBBB), height: 1.7),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => PaymentSuccessPage(event: event),
                    ),
                  );
                },
                icon: const Icon(Icons.lock_rounded),
                label: const Text('پرداخت و ثبت رزرو'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(title, style: const TextStyle(color: Color(0xFFAAAAAA))),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
