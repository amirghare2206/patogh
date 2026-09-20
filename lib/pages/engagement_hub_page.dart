import 'package:flutter/material.dart';
import 'package:patogh/pages/patogh_passport_page.dart';
import 'package:patogh/pages/route_story_page.dart';
import 'package:patogh/pages/story_engine_page.dart';
import 'package:patogh/state/engagement_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class EngagementHubPage extends StatelessWidget {
  const EngagementHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تجربه و کشف پاتوق'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: engagementState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF44311E), Color(0xFF181818)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: PatoghTheme.orange,
                      size: 38,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'امتیاز تجربه',
                            style: TextStyle(color: Color(0xFFAAAAAA)),
                          ),
                          Text(
                            '${engagementState.totalXp} XP',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${engagementState.socialRhythmMonths} ماه ریتم اجتماعی • ${engagementState.attendanceStreak} حضور متوالی بدون غیبت',
                            style: const TextStyle(
                              color: Color(0xFFBBBBBB),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _card(
                context,
                title: 'گذرنامه و چالش‌ها',
                subtitle: 'کشف شهرها، نشان‌ها و مأموریت‌هایی که به تجربه واقعی وصل‌اند.',
                icon: Icons.explore_rounded,
                page: const PatoghPassportPage(),
              ),
              _card(
                context,
                title: 'داستان یک پاتوق',
                subtitle: 'قبل، حین و بعد از هر رویداد یک روایت معنادار بساز.',
                icon: Icons.auto_stories_rounded,
                page: const StoryEnginePage(),
              ),
              _card(
                context,
                title: 'مسیر پاتوق',
                subtitle: 'در سفر، قصه مکان، مردم و فرصت‌های زنده مسیر را ببین و بشنو.',
                icon: Icons.route_rounded,
                page: const RouteStoryPage(),
              ),
              const SizedBox(height: 18),
              const Text(
                'اصل طراحی: امتیاز جای اعتبار را نمی‌گیرد. Reputation برای خوش‌قولی و رفتار واقعی است؛ XP فقط برای کشف، یادگیری و مشارکت.',
                style: TextStyle(
                  color: Color(0xFF8F8F8F),
                  height: 1.8,
                  fontSize: 11,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget page,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF2A2119),
            child: Icon(icon, color: PatoghTheme.orange),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ),
          trailing: const Icon(Icons.chevron_left_rounded),
          onTap: () =>
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => page)),
        ),
      ),
    );
  }
}
