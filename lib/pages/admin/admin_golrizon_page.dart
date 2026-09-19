import 'package:flutter/material.dart';
import 'package:patogh/models/v10_models.dart';
import 'package:patogh/state/v10_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class AdminGolrizonPage extends StatelessWidget {
  const AdminGolrizonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت گل‌ریزون'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: v10State,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'کمپین‌های عمومی قبل از دریافت پول واقعی باید از نظر هویت ذی‌نفع، هدف مصرف، مدارک و مسیر تسویه بررسی شوند.',
                style: TextStyle(color: Color(0xFFAAAAAA), height: 1.7),
              ),
              const SizedBox(height: 16),
              ...v10State.golrizons.map(
                (campaign) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.volunteer_activism_rounded,
                            color: PatoghTheme.orange,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              campaign.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Chip(label: Text(campaign.status.label)),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(campaign.purpose.label),
                      Text(
                        campaign.beneficiaryLabel,
                        style: const TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 11,
                        ),
                      ),
                      if (campaign.status ==
                          GolrizonStatus.pendingApproval) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () =>
                                    v10State.approveGolrizon(campaign.id),
                                child: const Text('تأیید'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    v10State.rejectGolrizon(campaign.id),
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
            ],
          );
        },
      ),
    );
  }
}
