import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class EventRequestPage extends StatelessWidget {
  const EventRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('درخواست رویداد'),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'اگر رویداد موردنظرت در پاتوق نیست درخواست بده. درخواست‌های مشابه تجمیع می‌شوند تا ادمین و برگزارکننده‌ها تقاضای واقعی را ببینند.',
                  style: TextStyle(height: 1.7, color: Color(0xFFBBBBBB)),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => _newRequest(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('ثبت درخواست جدید'),
              ),
              const SizedBox(height: 18),
              const Text(
                'درخواست‌های پرتقاضا',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
              const SizedBox(height: 10),
              ...appState.eventRequests.map(
                (request) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        request.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${request.city} • ${request.category} • ${request.ageRange}',
                        style: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '${request.supporters} متقاضی',
                            style: const TextStyle(
                              color: PatoghTheme.orange,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () =>
                                appState.supportEventRequest(request.id),
                            icon: const Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 18,
                            ),
                            label: const Text('من هم می‌خوام'),
                          ),
                        ],
                      ),
                      Text(
                        request.status,
                        style: const TextStyle(
                          color: PatoghTheme.green,
                          fontSize: 10,
                        ),
                      ),
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

  Future<void> _newRequest(BuildContext context) async {
    final title = TextEditingController();
    final city = TextEditingController(text: appState.profile?.city ?? 'مشهد');
    final category = TextEditingController();
    final ageRange = TextEditingController(text: '۱۸ تا ۴۰');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('رویداد پیشنهادی'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'عنوان رویداد'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: city,
                decoration: const InputDecoration(labelText: 'شهر / منطقه'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: category,
                decoration: const InputDecoration(labelText: 'موضوع / دسته'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ageRange,
                decoration: const InputDecoration(labelText: 'رده سنی موردنظر'),
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
              if (title.text.trim().isEmpty) return;
              await appState.addEventRequest(
                title: title.text.trim(),
                city: city.text.trim(),
                category: category.text.trim().isEmpty
                    ? 'سایر'
                    : category.text.trim(),
                ageRange: ageRange.text.trim(),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('ارسال برای ادمین'),
          ),
        ],
      ),
    );

    title.dispose();
    city.dispose();
    category.dispose();
    ageRange.dispose();
  }
}
