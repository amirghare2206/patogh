import 'package:flutter/material.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/pages/payment_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class EventDetailPage extends StatefulWidget {
  final PatoghEvent event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final score = appState.matchScore(event.tags);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات پاتوق'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 120),
            children: [
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(colors: event.gradient),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(event.icon, size: 92, color: Colors.white),
                    ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Chip(label: Text('سازگاری $score٪')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: event.isFull
                      ? const Color(0xFFC7CAD0)
                      : const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(28),
                  border: event.isFull
                      ? null
                      : Border.all(color: PatoghTheme.blue),
                ),
                child: Text(
                  event.isFull
                      ? 'تکمیل ظرفیت'
                      : '${event.seatsLeft} صندلی باقی مانده',
                  style: TextStyle(
                    color: event.isFull
                        ? const Color(0xFF222222)
                        : Colors.white,
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
                      'محدوده: ${event.area}\n${event.exactLocationNote}',
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _tab(
                      'جزئیات پاتوق',
                      selectedTab == 0,
                      () => setState(() => selectedTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _tab(
                      'نظر کاربران',
                      selectedTab == 1,
                      () => setState(() => selectedTab = 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (selectedTab == 0)
                Text(
                  event.description,
                  style: const TextStyle(height: 1.9, color: Color(0xFFE1E1E1)),
                )
              else
                const Text(
                  '★★★★★\nتجربه خوب و جمع صمیمی بود.',
                  style: TextStyle(height: 2),
                ),
            ],
          ),
        ),
      ),
      bottomSheet: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              final reserved = appState.reservedIds.contains(event.id);
              final waitlisted = appState.waitlistIds.contains(event.id);

              return Container(
                height: 96,
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF151515),
                  border: Border(top: BorderSide(color: Color(0xFF252525))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 112,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${event.finalPrice}\nتومان',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: reserved || waitlisted
                            ? null
                            : () async {
                                if (event.isFull) {
                                  await appState.joinWaitlist(event.id);
                                  return;
                                }
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PaymentPage(event: event),
                                  ),
                                );
                                if (mounted) setState(() {});
                              },
                        child: Text(
                          reserved
                              ? 'رزرو شده'
                              : waitlisted
                              ? 'در لیست انتظار'
                              : event.isFull
                              ? 'لیست انتظار'
                              : 'رزرو پاتوق',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 30),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text(value, style: const TextStyle(height: 1.6)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tab(String title, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? PatoghTheme.blue : const Color(0xFF444444),
              width: selected ? 3 : 1,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF888888),
            fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
