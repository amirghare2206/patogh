import 'package:flutter/material.dart';
import 'package:patogh/config/app_config.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/pages/payment_success_page.dart';
import 'package:patogh/services/platform_services.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  final PatoghEvent event;
  final int? checkoutTotal;
  final String? checkoutNote;

  const PaymentPage({
    super.key,
    required this.event,
    this.checkoutTotal,
    this.checkoutNote,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

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
                    _line(
                      'مبلغ',
                      '${widget.checkoutTotal ?? event.finalPrice} تومان',
                    ),
                    if (widget.checkoutNote != null)
                      _line('جزئیات', widget.checkoutNote!),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                AppConfig.usePaymentApi
                    ? 'با ادامه، درگاه پرداخت امن باز می‌شود.'
                    : 'حالت Demo فعال است؛ پرداخت به‌صورت آزمایشی ثبت می‌شود.',
                style: const TextStyle(color: Color(0xFFBBBBBB), height: 1.7),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: loading ? null : _startPayment,
                icon: const Icon(Icons.lock_rounded),
                label: Text(loading ? 'در حال اتصال...' : 'پرداخت و ثبت رزرو'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startPayment() async {
    setState(() => loading = true);

    try {
      final result = await PlatformServices.createPayment(
        event: widget.event,
        amount: widget.checkoutTotal,
      );

      if (!mounted) return;

      if (result.demo) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(event: widget.event),
          ),
        );
        return;
      }

      final url = result.url;
      if (url == null || url.isEmpty) {
        throw Exception('آدرس درگاه از سرور دریافت نشد.');
      }

      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_self',
      );

      if (!opened && mounted) {
        throw Exception('باز کردن درگاه ممکن نشد.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
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
