import 'package:flutter/material.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class EnterprisePage extends StatelessWidget {
  const EnterprisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پاتوق سازمانی B2B / B2E'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final org = appState.organizations.first;
          final remaining = org.monthlyBudget - org.usedBudget;

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      org.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      org.type,
                      style: const TextStyle(color: PatoghTheme.orange),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _metric('کارمند', '${org.employees}')),
                        Expanded(
                          child: _metric(
                            'بودجه ماه',
                            '${org.monthlyBudget ~/ 1000000} م',
                          ),
                        ),
                        Expanded(
                          child: _metric(
                            'باقیمانده',
                            '${remaining ~/ 1000000} م',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _section(
                'B2B • رویداد شرکتی',
                'شرکت درخواست تیم‌سازی، همایش، گردهمایی یا پذیرایی سازمانی ثبت می‌کند و میزبان‌ها/آژانس‌های تأییدشده پیشنهاد می‌دهند.',
                Icons.business_center_rounded,
              ),
              _section(
                'B2E • مزایای کارمندی',
                'سازمان می‌تواند برای هر کارمند اعتبار ماهانه، سقف هر رزرو و دسته‌های مجاز تعریف کند.',
                Icons.badge_rounded,
              ),
              _section(
                'پذیرایی سازمانی میزبان',
                'میزبان می‌تواند پکیج جلسه، صبحانه شرکتی، ناهار، فضای خصوصی، پروژکتور و خدمات VIP ارائه کند.',
                Icons.room_service_rounded,
              ),
              const SizedBox(height: 6),
              FilledButton.icon(
                onPressed: () => _newCorporateRequest(context),
                icon: const Icon(Icons.add_business_rounded),
                label: const Text('ثبت درخواست سازمانی'),
              ),
              const SizedBox(height: 16),
              const Text(
                'درخواست‌های سازمانی',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
              const SizedBox(height: 8),
              ...appState.corporateRequests.map(
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
                        '${request.city} • ${request.people} نفر • بودجه ${request.budget ~/ 1000000} میلیون',
                        style: const TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 10,
                        ),
                      ),
                      if (request.catering)
                        const Text(
                          'پذیرایی سازمانی لازم است',
                          style: TextStyle(
                            color: PatoghTheme.orange,
                            fontSize: 10,
                          ),
                        ),
                      const SizedBox(height: 6),
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
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'نمونه B2E',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'اعتبار ماهانه کارمند: ۱,۰۰۰,۰۰۰ تومان\nحداکثر هر رزرو: ۵۰۰,۰۰۰ تومان\nدسته‌های مجاز: آموزشی، ورزشی، فرهنگی',
                      style: TextStyle(
                        color: Color(0xFFBBBBBB),
                        height: 1.7,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _metric(String label, String value) {
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
        Text(
          label,
          style: const TextStyle(color: Color(0xFF999999), fontSize: 9),
        ),
      ],
    );
  }

  Widget _section(String title, String body, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: PatoghTheme.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 11,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _newCorporateRequest(BuildContext context) async {
    final title = TextEditingController();
    final city = TextEditingController(text: 'مشهد');
    final people = TextEditingController(text: '50');
    final budget = TextEditingController(text: '100000000');
    var catering = true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('درخواست سازمانی جدید'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'عنوان / نوع برنامه',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: city,
                  decoration: const InputDecoration(labelText: 'شهر'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: people,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'تعداد نفرات'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: budget,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'بودجه'),
                ),
                SwitchListTile(
                  value: catering,
                  onChanged: (value) => setLocalState(() => catering = value),
                  title: const Text('پذیرایی لازم است'),
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
                final p = int.tryParse(people.text.trim());
                final b = int.tryParse(budget.text.trim());
                if (title.text.trim().isEmpty || p == null || b == null) return;
                await appState.addCorporateRequest(
                  title: title.text.trim(),
                  city: city.text.trim(),
                  people: p,
                  budget: b,
                  catering: catering,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('ثبت درخواست'),
            ),
          ],
        ),
      ),
    );

    title.dispose();
    city.dispose();
    people.dispose();
    budget.dispose();
  }
}
