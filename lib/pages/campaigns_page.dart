import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class CampaignsPage extends StatelessWidget {
  const CampaignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جشنواره‌ها و کدهای تخفیف'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          ...appState.discountCampaigns.map(
            (campaign) => Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF2A2A2A),
                    child: Text(
                      '${campaign.percent}٪',
                      style: const TextStyle(
                        color: PatoghTheme.orange,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          campaign.audience,
                          style: const TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          'کد: ${campaign.code} • سقف ${campaign.maxDiscount} تومان',
                          style: const TextStyle(
                            color: PatoghTheme.green,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'کمپین‌ها در Production می‌توانند بر اساس شهر، دسته، میزبان، آژانس، کاربر جدید، رزرو گروهی، B2E، زمان مانده تا رویداد و سقف مصرف هدف‌گذاری شوند.',
            style: TextStyle(
              color: Color(0xFFAAAAAA),
              height: 1.7,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
