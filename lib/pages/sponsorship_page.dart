import 'package:flutter/material.dart';
import 'package:patogh/models/user_role.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class SponsorshipPage extends StatelessWidget {
  const SponsorshipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اسپانسرینگ رویداد'),
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
              const Text(
                'شرکت، سازمان، کارخانه، برند یا شخص حقیقی می‌تواند تمام یا بخشی از هزینه رویداد را با هدف تبلیغ، یادبود، مسئولیت اجتماعی یا عام‌المنفعه تأمین کند.',
                style: TextStyle(color: Color(0xFFAAAAAA), height: 1.7),
              ),
              if (appState.role == UserRole.admin ||
                  appState.role == UserRole.organizer) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _newPlan(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('ثبت حمایت / اسپانسر جدید'),
                ),
              ],
              const SizedBox(height: 16),
              ...appState.sponsorships.map((plan) {
                final full = plan.registered >= plan.capacity;
                final progress = plan.capacity == 0
                    ? 0.0
                    : plan.registered / plan.capacity;
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
                          const Icon(
                            Icons.volunteer_activism_rounded,
                            color: PatoghTheme.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              plan.eventTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${plan.sponsorName} • ${plan.purpose}',
                        style: const TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0).toDouble(),
                        minHeight: 9,
                        borderRadius: BorderRadius.circular(20),
                        color: full ? PatoghTheme.green : PatoghTheme.orange,
                        backgroundColor: const Color(0xFF2A2A2A),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${plan.registered}/${plan.capacity} ثبت‌نام • ${plan.invited} دعوت ارسال‌شده',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        full ? 'ظرفیت کامل است؛ ارسال دعوت خودکار متوقف شده.' : 'دعوت کاربران واجد شرایط تا تکمیل ظرفیت ادامه دارد.',
                        style: TextStyle(
                          color: full
                              ? PatoghTheme.green
                              : const Color(0xFFFFC36B),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ارزش واقعی هر صندلی: ${plan.unitCost} تومان',
                        style: const TextStyle(
                          color: Color(0xFF8F8F8F),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        plan.status,
                        style: const TextStyle(
                          color: PatoghTheme.blue,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF221B16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'کاربران دعوت‌شده باید قبل از ثبت‌نام شرایط No-show را تأیید کنند. غیبت بدون لغو باعث افت سنگین اعتبار حضور و در رویدادهای مشمول، بدهی هزینه صندلی + جریمه و مسدود شدن رزرو تا تسویه می‌شود.',
                  style: TextStyle(
                    color: Color(0xFFD7C5B4),
                    height: 1.7,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _newPlan(BuildContext context) async {
    final sponsor = TextEditingController();
    final purpose = TextEditingController(text: 'مسئولیت اجتماعی');
    final event = TextEditingController();
    final capacity = TextEditingController(text: '30');
    final unitCost = TextEditingController(text: '700000');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حمایت جدید'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sponsor,
                decoration: const InputDecoration(labelText: 'نام اسپانسر'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: purpose,
                decoration: const InputDecoration(labelText: 'هدف حمایت'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: event,
                decoration: const InputDecoration(labelText: 'عنوان رویداد'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: capacity,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ظرفیت'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: unitCost,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ارزش واقعی هر صندلی',
                ),
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
              final c = int.tryParse(capacity.text.trim());
              final cost = int.tryParse(unitCost.text.trim());
              if (sponsor.text.trim().isEmpty ||
                  event.text.trim().isEmpty ||
                  c == null ||
                  cost == null) {
                return;
              }
              await appState.addSponsorship(
                sponsorName: sponsor.text.trim(),
                purpose: purpose.text.trim(),
                eventTitle: event.text.trim(),
                capacity: c,
                unitCost: cost,
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('ثبت'),
          ),
        ],
      ),
    );

    sponsor.dispose();
    purpose.dispose();
    event.dispose();
    capacity.dispose();
    unitCost.dispose();
  }
}
