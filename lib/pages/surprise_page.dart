import 'package:flutter/material.dart';
import 'package:patogh/models/v10_models.dart';
import 'package:patogh/state/v10_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class SurprisePage extends StatelessWidget {
  const SurprisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: v10State,
        builder: (context, _) {
          return Scaffold(
            body: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سورپرایز',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'با آدم‌هایی که خودت انتخاب می‌کنی یک غافلگیری واقعی بساز.',
                            style: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => _createSurprise(context),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF503040), Color(0xFF1A1718)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.card_giftcard_rounded,
                        color: PatoghTheme.orange,
                        size: 38,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'سورپرایز از دید فرد هدف مخفی می‌ماند',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'شروع‌کننده مشخص می‌کند چه کسانی از حلقه، شماره موبایل یا نام کاربری وارد برنامه‌ریزی شوند. تا زمان رونمایی، فرد هدف به محتوای این برنامه دسترسی ندارد.',
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
                ...v10State.surprises.map(
                  (plan) => _surpriseCard(context, plan),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _surpriseCard(BuildContext context, SurprisePlan plan) {
    return Container(
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
              const Icon(Icons.celebration_rounded, color: PatoghTheme.orange),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  plan.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              Chip(label: Text(plan.status.label)),
            ],
          ),
          const SizedBox(height: 10),
          Text('برای: ${plan.targetLabel}'),
          const SizedBox(height: 4),
          Text(
            '${plan.occasion} • ${plan.revealLabel}',
            style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            'همراه‌ها: ${plan.audienceLabel} • ${plan.joinedCount}/${plan.invitedCount}',
            style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => v10State.inviteToSurprise(plan.id),
                  icon: const Icon(Icons.person_add_rounded),
                  label: const Text('دعوت همراه'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: plan.status == SurpriseStatus.revealed
                      ? null
                      : () => _confirmReveal(context, plan),
                  icon: const Icon(Icons.visibility_rounded),
                  label: Text(
                    plan.status == SurpriseStatus.revealed
                        ? 'رونمایی شده'
                        : 'رونمایی',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _createSurprise(BuildContext context) async {
    final title = TextEditingController();
    final target = TextEditingController();
    final reveal = TextEditingController();
    var occasion = 'تولد';
    var audience = 'دوستان نزدیک';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('سورپرایز جدید'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: occasion,
                      decoration: const InputDecoration(labelText: 'مناسبت'),
                      items:
                          const [
                                'تولد',
                                'سالگرد',
                                'موفقیت',
                                'بازگشت از سفر',
                                'قدردانی',
                                'سایر',
                              ]
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => occasion = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: title,
                      decoration: const InputDecoration(labelText: 'عنوان'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: target,
                      decoration: const InputDecoration(
                        labelText: 'فرد هدف (نام کاربری یا شماره موبایل)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: reveal,
                      decoration: const InputDecoration(
                        labelText: 'زمان رونمایی',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: audience,
                      decoration: const InputDecoration(
                        labelText: 'همراه‌های اولیه',
                      ),
                      items:
                          const [
                                'دوستان نزدیک',
                                'خانواده',
                                'یک حلقه مشخص',
                                'دعوت دستی',
                              ]
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => audience = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('انصراف'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (title.text.trim().isEmpty ||
                        target.text.trim().isEmpty) {
                      return;
                    }

                    await v10State.createSurprise(
                      title: title.text.trim(),
                      occasion: occasion,
                      targetLabel: target.text.trim(),
                      revealLabel: reveal.text.trim().isEmpty
                          ? 'زمان تعیین نشده'
                          : reveal.text.trim(),
                      audienceLabel: audience,
                    );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('ساخت'),
                ),
              ],
            );
          },
        );
      },
    );

    title.dispose();
    target.dispose();
    reveal.dispose();
  }

  Future<void> _confirmReveal(BuildContext context, SurprisePlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('رونمایی سورپرایز؟'),
          content: Text(
            'بعد از رونمایی، ${plan.targetLabel} می‌تواند محتوای آماده‌شده برای خودش را ببیند.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('نه'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('رونمایی کن'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await v10State.revealSurprise(plan.id);
    }
  }
}
