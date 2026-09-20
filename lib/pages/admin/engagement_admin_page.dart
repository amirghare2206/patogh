import 'package:flutter/material.dart';
import 'package:patogh/state/engagement_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class EngagementAdminPage extends StatelessWidget {
  const EngagementAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: engagementState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'موتور تعامل و داستان',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'مدیریت Challenge، Passport، روایت‌های محلی و محتوای مسیر.',
                style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('${engagementState.quests.length} چالش')),
                  Chip(
                    label: Text('${engagementState.stamps.length} مهر گذرنامه'),
                  ),
                  Chip(label: Text('${engagementState.routes.length} مسیر')),
                  Chip(
                    label: Text(
                      '${engagementState.submissions.where((item) => item.status == 'pending').length} روایت منتظر بررسی',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'روایت‌های ارسالی',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...engagementState.submissions.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            item.status,
                            style: const TextStyle(
                              color: PatoghTheme.orange,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${item.placeLabel} • ${item.author}',
                        style: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        item.text,
                        style: const TextStyle(fontSize: 11, height: 1.6),
                      ),
                      if (item.status == 'pending') ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () => engagementState
                                    .reviewSubmission(item.id, true),
                                child: const Text('تأیید'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => engagementState
                                    .reviewSubmission(item.id, false),
                                child: const Text('رد'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Production: روایت‌های تاریخی و محلی باید منبع، صاحب اثر، وضعیت حقوق انتشار، مکان جغرافیایی و وضعیت تأیید تحریریه داشته باشند.',
                style: TextStyle(
                  color: Color(0xFF8F8F8F),
                  fontSize: 10,
                  height: 1.7,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
