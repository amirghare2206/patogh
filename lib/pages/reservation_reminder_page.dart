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
            padding: const EdgeInsets.all(22),
            children: [
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(colors: event.gradient),
                ),
                child: Icon(event.icon, size: 88, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                waitlist ? 'در لیست انتظار' : 'رزرو تأیید شده',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Text('${event.date} • ${event.time} • ${event.area}'),
              const SizedBox(height: 12),
              Text(
                event.exactLocationNote,
                style: const TextStyle(color: Color(0xFFBBBBBB)),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  await appState.cancelReservation(event.id);
                  if (context.mounted) Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close_rounded),
                label: const Text('لغو رزرو'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
