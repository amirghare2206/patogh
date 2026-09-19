import 'package:flutter/material.dart';
import 'package:patogh/pages/reputation_page.dart';
import 'package:patogh/pages/post_event_feedback_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class FeedbackCenterPage extends StatelessWidget {
  const FeedbackCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اعتبار، حضور و بازخورد'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PostEventFeedbackPage(),
                  ),
                ),
                icon: const Icon(Icons.rate_review_rounded),
                label: const Text('ثبت بازخورد بعد از رویداد'),
              ),
              const SizedBox(height: 14),
              _attendance(),
              const SizedBox(height: 14),
              _entityLinks(context),
              const SizedBox(height: 14),
              _verifiedFeedback(),
            ],
          );
        },
      ),
    );
  }

  Widget _attendance() {
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
            'اعتبار حضور من',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${appState.attendanceReputation}/100',
                  style: const TextStyle(
                    color: PatoghTheme.orange,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'بدهی باز',
                    style: TextStyle(color: Color(0xFF999999), fontSize: 10),
                  ),
                  Text(
                    '${appState.outstandingDebt} تومان',
                    style: TextStyle(
                      color: appState.outstandingDebt > 0
                          ? const Color(0xFFFF9B9B)
                          : PatoghTheme.green,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...appState.attendanceHistory.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Icon(
                    item.impact < 0
                        ? Icons.trending_down_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 16,
                    color: item.impact < 0
                        ? const Color(0xFFFF9B9B)
                        : PatoghTheme.green,
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(item.title)),
                  Text(
                    item.status,
                    style: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (appState.outstandingDebt > 0) ...[
            const SizedBox(height: 10),
            FilledButton(
              onPressed: appState.settleDebt,
              child: const Text('تسویه بدهی Demo'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _entityLinks(BuildContext context) {
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
            'صفحه اعتبار موجودیت‌ها',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
          const SizedBox(height: 8),
          _button(context, 'کافه روشن', 'venue-roshan'),
          _button(context, 'آژانس تجربه نو', 'org-novin'),
          _button(context, 'مریم رضایی • هماهنگ‌کننده', 'coord-demo'),
          _button(context, 'شب بازی پاتوق • رویداد', 'event-demo'),
          _button(context, 'اعتبار شرکت‌کننده', 'user-demo'),
        ],
      ),
    );
  }

  Widget _button(BuildContext context, String title, String id) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReputationPage(reputationId: id)),
        ),
        icon: const Icon(Icons.verified_rounded),
        label: Text(title),
      ),
    );
  }

  Widget _verifiedFeedback() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'بازخوردهای تأییدشده اخیر',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        const SizedBox(height: 10),
        ...appState.feedbackEntries.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.all(13),
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
                      size: 16,
                      color: PatoghTheme.green,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.targetTitle,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text('${item.score}/5'),
                  ],
                ),
                const SizedBox(height: 7),
                Text(item.comment, style: const TextStyle(height: 1.6)),
                Text(
                  item.eventTitle,
                  style: const TextStyle(color: Color(0xFF888888), fontSize: 9),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
