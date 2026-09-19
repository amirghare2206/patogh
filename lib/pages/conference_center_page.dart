import 'package:flutter/material.dart';
import 'package:patogh/state/v9_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class ConferenceCenterPage extends StatelessWidget {
  const ConferenceCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('همایش و رویداد بزرگ'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: v9State,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF18304A), Color(0xFF171717)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.co_present_rounded,
                      color: PatoghTheme.orange,
                      size: 36,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'ثبت‌نام و مدیریت همایش',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'ثبت‌نام، بلیت چندسطحی، QR Check-in، برنامه جلسات، سخنران، غرفه اسپانسر، گواهی حضور، نظرسنجی و آلبوم بعد از رویداد.',
                      style: TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 11,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ...v9State.conferences.map(
                (conference) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        conference.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${conference.city} • ${conference.dateLabel}',
                        style: const TextStyle(color: Color(0xFFAAAAAA)),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: conference.registered / conference.capacity,
                        minHeight: 9,
                        borderRadius: BorderRadius.circular(20),
                        backgroundColor: const Color(0xFF2A2A2A),
                        color: PatoghTheme.orange,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${conference.registered} ثبت‌نام از ${conference.capacity} ظرفیت',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          ...conference.ticketTiers.map(
                            (tier) => Chip(label: Text('بلیت $tier')),
                          ),
                          if (conference.certificateEnabled)
                            const Chip(label: Text('گواهی حضور')),
                          if (conference.sponsorBoothsEnabled)
                            const Chip(label: Text('غرفه اسپانسر')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: Color(0xFF2A2A2A)),
                      Text(
                        'برنامه: ${conference.speakers.join(' • ')}',
                        style: const TextStyle(
                          color: Color(0xFFBBBBBB),
                          fontSize: 11,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
