import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class SocialDiscoveryPage extends StatelessWidget {
  const SocialDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعامل هوشمند'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _section(
            'آشناهای قبلی در جمع',
            'قبل از رزرو، بدون افشای هویت کامل می‌فهمی چند نفر را قبلاً در پاتوق دیده‌ای.',
            Icons.people_alt_rounded,
            Column(
              children: appState.familiarFaces
                  .map(
                    (face) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_rounded),
                      ),
                      title: Text(face.name),
                      subtitle: Text('${face.sharedEvents} رویداد مشترک'),
                      trailing: face.mutualReconnect
                          ? const Chip(label: Text('ارتباط دوطرفه'))
                          : const Text(
                              'ناشناس تا رضایت دوطرفه',
                              style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF999999),
                              ),
                            ),
                    ),
                  )
                  .toList(),
            ),
          ),
          _section(
            'پاتوق دوباره',
            'بعد از یک حضور موفق، اگر هر دو طرف موافق باشند می‌توانید برای برنامه بعدی دوباره همدیگر را انتخاب کنید.',
            Icons.replay_circle_filled_rounded,
            OutlinedButton.icon(
              onPressed: () => _message(
                context,
                'درخواست ارتباط دوطرفه برای هم‌پاتوقی‌های قبلی ثبت شد.',
              ),
              icon: const Icon(Icons.favorite_border_rounded),
              label: const Text('انتخاب هم‌پاتوقی‌های قبلی'),
            ),
          ),
          _section(
            'رأی‌گیری زمان رویداد',
            'قبل از قطعی شدن برنامه، کاربران می‌توانند به زمان‌های پیشنهادی رأی دهند.',
            Icons.how_to_vote_rounded,
            Column(
              children: appState.eventTimeOptions
                  .map(
                    (option) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(option.label),
                      subtitle: Text(
                        '${option.yes} موافق • ${option.maybe} شاید',
                      ),
                      trailing: IconButton(
                        onPressed: () => _message(
                          context,
                          'رأی شما برای ${option.label} ثبت شد.',
                        ),
                        icon: const Icon(Icons.thumb_up_alt_outlined),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          _section(
            'فرم پویا و رضایت‌نامه',
            'هر رویداد می‌تواند سؤال‌های مخصوص و شرایط حضور خودش را داشته باشد.',
            Icons.fact_check_rounded,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: appState.registrationQuestions
                  .map(
                    (q) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            q.required
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: 16,
                            color: PatoghTheme.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(q.label)),
                          Text(
                            q.type,
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          _section(
            'آلبوم مشترک رویداد',
            'بعد از رویداد، شرکت‌کننده‌های تأییدشده می‌توانند خاطره و عکس‌های مجاز را به آلبوم مشترک اضافه کنند.',
            Icons.photo_library_rounded,
            Column(
              children: appState.eventAlbum
                  .map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.photo_rounded,
                        color: PatoghTheme.orange,
                      ),
                      title: Text(entry.eventTitle),
                      subtitle: Text('${entry.author} • ${entry.caption}'),
                      trailing: entry.verifiedAttendance
                          ? const Icon(
                              Icons.verified_rounded,
                              color: PatoghTheme.green,
                              size: 18,
                            )
                          : null,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String subtitle, IconData icon, Widget body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: PatoghTheme.orange),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 11,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 12),
          body,
        ],
      ),
    );
  }

  void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
