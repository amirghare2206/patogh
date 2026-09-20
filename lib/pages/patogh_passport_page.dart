import 'package:flutter/material.dart';
import 'package:patogh/state/engagement_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class PatoghPassportPage extends StatelessWidget {
  const PatoghPassportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('گذرنامه پاتوق'),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _xp('اکتشاف', engagementState.discoveryXp),
                  _xp('فرهنگ', engagementState.cultureXp),
                  _xp('اجتماعی', engagementState.socialXp),
                  _xp('مشارکت', engagementState.contributionXp),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'چالش‌های من',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...engagementState.quests.map(
                (quest) => Container(
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
                          Expanded(
                            child: Text(
                              quest.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            '+${quest.rewardXp} XP',
                            style: const TextStyle(
                              color: PatoghTheme.orange,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        quest.description,
                        style: const TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: quest.ratio,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${quest.progress} از ${quest.target}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF999999),
                        ),
                      ),
                      if (!quest.completed)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () =>
                                engagementState.completeQuestDemo(quest.id),
                            child: const Text('تکمیل دمو'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'مهرهای گذرنامه',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...engagementState.stamps.map(
                (stamp) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: stamp.unlocked
                        ? const Color(0xFF292116)
                        : const Color(0xFF171717),
                    borderRadius: BorderRadius.circular(18),
                    child: ListTile(
                      leading: Icon(
                        stamp.unlocked
                            ? Icons.verified_rounded
                            : Icons.lock_outline_rounded,
                        color: stamp.unlocked
                            ? PatoghTheme.orange
                            : Colors.white54,
                      ),
                      title: Text(
                        stamp.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        '${stamp.province} / ${stamp.city} • ${stamp.subtitle}',
                        style: const TextStyle(fontSize: 10),
                      ),
                      trailing: stamp.unlocked
                          ? const Text(
                              'باز شده',
                              style: TextStyle(
                                color: PatoghTheme.orange,
                                fontSize: 10,
                              ),
                            )
                          : TextButton(
                              onPressed: () =>
                                  engagementState.unlockStamp(stamp.id),
                              child: const Text('دمو'),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _xp(String label, int value) => Chip(label: Text('$label: $value XP'));
}
