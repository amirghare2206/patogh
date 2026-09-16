import 'package:flutter/material.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/state/app_state.dart';

class PaymentSuccessPage extends StatefulWidget {
  final PatoghEvent event;

  const PaymentSuccessPage({super.key, required this.event});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  @override
  void initState() {
    super.initState();
    appState.reserve(widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFF173628),
                  child: Icon(
                    Icons.check_rounded,
                    size: 58,
                    color: Color(0xFF7BE0A8),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'رزرو پاتوق با موفقیت ثبت شد',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.event.title,
                  style: const TextStyle(color: Color(0xFFBBBBBB)),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A2A),
                    minimumSize: const Size.fromHeight(54),
                  ),
                  child: const Text('بازگشت'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
