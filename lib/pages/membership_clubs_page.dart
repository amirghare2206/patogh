import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class MembershipClubsPage extends StatelessWidget {
  const MembershipClubsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('باشگاه‌های پاتوق'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'عضویت رایگان یا اشتراکی برای اولویت رزرو، رویدادهای مخصوص اعضا و کانال اختصاصی.',
              style: TextStyle(color: Color(0xFFAAAAAA), height: 1.7),
            ),
            const SizedBox(height: 16),
            ...appState.membershipClubs.map(
              (club) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
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
                          Icons.workspace_premium_rounded,
                          color: PatoghTheme.orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            club.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          '${club.members} عضو',
                          style: const TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      club.subtitle,
                      style: const TextStyle(
                        color: Color(0xFFBBBBBB),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      club.monthlyPrice == 0
                          ? 'عضویت رایگان'
                          : 'ماهانه ${club.monthlyPrice} تومان',
                      style: const TextStyle(
                        color: PatoghTheme.orange,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => appState.toggleMembershipClub(club.id),
                      child: Text(club.joined ? 'عضو هستی ✓' : 'عضویت'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
