import 'package:flutter/material.dart';
import 'package:patogh/models/ecosystem_models.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class ReputationPage extends StatelessWidget {
  final String reputationId;

  const ReputationPage({super.key, required this.reputationId});

  @override
  Widget build(BuildContext context) {
    final profile = appState.reputationById(reputationId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('اعتبار و بازخورد'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _header(profile),
          const SizedBox(height: 14),
          _claims(profile),
          const SizedBox(height: 14),
          _metrics(profile),
          const SizedBox(height: 14),
          _feedback(profile),
        ],
      ),
    );
  }

  Widget _header(ReputationProfile profile) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFF2A2A2A),
            child: Icon(
              Icons.verified_rounded,
              color: PatoghTheme.orange,
              size: 34,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          Text(
            profile.entityType,
            style: const TextStyle(color: Color(0xFFAAAAAA)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _stat('امتیاز', profile.overall.toStringAsFixed(1)),
              ),
              Expanded(
                child: _stat('تجربه تأییدشده', '${profile.verifiedReviews}'),
              ),
              Expanded(child: _stat('اعتماد داده', '${profile.confidence}٪')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: PatoghTheme.orange,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF999999), fontSize: 9),
        ),
      ],
    );
  }

  Widget _claims(ReputationProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'ادعا در برابر تجربه واقعی',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ...profile.claims.map(
            (claim) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.record_voice_over_rounded,
                    color: PatoghTheme.blue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(claim)),
                  Text(
                    '${profile.claimMatch}٪ همخوانی',
                    style: const TextStyle(
                      color: PatoghTheme.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'این درصد از بازخوردهای حضور تأییدشده ساخته می‌شود؛ ادعای صاحب پروفایل و تجربه کاربران جدا نمایش داده می‌شوند.',
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 10,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metrics(ReputationProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'شاخص‌های کیفیت',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...profile.metrics.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(entry.key)),
                      Text(
                        entry.value.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: entry.value / 10,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(20),
                    color: PatoghTheme.orange,
                    backgroundColor: const Color(0xFF2A2A2A),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Color(0xFF303030)),
          const Text('نقاط قوت', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          ...profile.strengths.map(
            (item) => Text(
              '✓ $item',
              style: const TextStyle(color: PatoghTheme.green, height: 1.7),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'قابل بهبود',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          ...profile.improvements.map(
            (item) => Text(
              '• $item',
              style: const TextStyle(color: Color(0xFFFFC36B), height: 1.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedback(ReputationProfile profile) {
    final entries = appState.feedbackEntries
        .where((item) => item.targetTitle == profile.title)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'نظرهای اخیر',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (entries.isEmpty)
          const Text(
            'هنوز بازخورد نمایشی ثبت نشده.',
            style: TextStyle(color: Color(0xFF999999)),
          )
        else
          ...entries.map(
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
                      const Icon(
                        Icons.verified_rounded,
                        color: PatoghTheme.green,
                        size: 17,
                      ),
                      const SizedBox(width: 5),
                      const Expanded(
                        child: Text(
                          'حضور تأییدشده',
                          style: TextStyle(
                            color: PatoghTheme.green,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        '${item.score}/5',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item.comment, style: const TextStyle(height: 1.6)),
                  const SizedBox(height: 5),
                  Text(
                    item.eventTitle,
                    style: const TextStyle(
                      color: Color(0xFF8F8F8F),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
