import 'package:flutter/material.dart';
import 'package:patogh/models/v11_models.dart';
import 'package:patogh/pages/create_event_page.dart';
import 'package:patogh/pages/memorial_center_page.dart';
import 'package:patogh/state/v11_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class TimeOccasionHubPage extends StatelessWidget {
  const TimeOccasionHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('زمان و مناسبت‌های پاتوق'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'امروز'),
              Tab(text: 'تقویم‌ها'),
              Tab(text: 'شخصی'),
              Tab(text: 'فرصت‌ها'),
              Tab(text: 'مموریال'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TodayTab(),
            _LayersTab(),
            _PersonalTab(),
            _OpportunitiesTab(),
            MemorialCenterEmbedded(),
          ],
        ),
      ),
    );
  }
}

class _TodayTab extends StatelessWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: v11State,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A2C19), Color(0xFF171717)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'امروز چه خبره؟',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'پاتوق مناسبت‌ها، تقاضا، فصل، مسابقات و ظرفیت میزبان‌ها را کنار هم می‌گذارد و فرصت رویداد می‌سازد.',
                    style: TextStyle(color: Color(0xFFD0D0D0), height: 1.7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'مناسبت‌های قابل استفاده',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...v11State.occasions
                .where((item) => v11State.enabledLayers.contains(item.layer))
                .take(4)
                .map((item) => _occasionCard(item)),
            const SizedBox(height: 18),
            const Text(
              'پیشنهاد موتور فرصت',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...v11State.opportunities
                .take(2)
                .map((item) => _opportunityCard(context, item)),
          ],
        );
      },
    );
  }
}

class _LayersTab extends StatelessWidget {
  const _LayersTab();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: v11State,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'لایه‌های تقویم',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'هر لایه را می‌توانی روشن یا خاموش کنی. تاریخ‌های پویا در Production از منبع سروری معتبر به‌روزرسانی می‌شوند.',
              style: TextStyle(color: Color(0xFFAAAAAA), height: 1.6),
            ),
            const SizedBox(height: 14),
            ...PatoghCalendarLayer.values.map(
              (layer) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(18),
                  child: SwitchListTile(
                    value: v11State.enabledLayers.contains(layer),
                    onChanged: (_) => v11State.toggleLayer(layer),
                    title: Text(
                      layer.label,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    secondary: const Icon(
                      Icons.calendar_month_rounded,
                      color: PatoghTheme.orange,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'نمونه مناسبت‌ها',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...v11State.occasions
                .where((item) => v11State.enabledLayers.contains(item.layer))
                .map(_occasionCard),
          ],
        );
      },
    );
  }
}

class _PersonalTab extends StatelessWidget {
  const _PersonalTab();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: v11State,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'مناسبت‌های شخصی',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _addPersonalOccasion(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('افزودن'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'تولد، سالگرد، مناسبت خانوادگی یا هر تاریخ دلخواه؛ با یادآور برای خودت یا حلقه‌ات.',
              style: TextStyle(color: Color(0xFFAAAAAA), height: 1.6),
            ),
            const SizedBox(height: 14),
            ...v11State.personalOccasions.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
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
                        const Icon(
                          Icons.event_repeat_rounded,
                          color: PatoghTheme.orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(
                          item.dateLabel,
                          style: const TextStyle(color: PatoghTheme.orange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item.occasionType} • ${item.audience.label}',
                      style: const TextStyle(
                        color: Color(0xFFBBBBBB),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'یادآورها: ${item.reminderLabels.join('، ')}',
                      style: const TextStyle(
                        color: Color(0xFF8F8F8F),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (item.suggestEvents)
                          const Chip(label: Text('پیشنهاد رویداد')),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => v11State.scheduleDemoReminder(item),
                          icon: const Icon(Icons.notifications_active_rounded),
                          label: const Text('ثبت یادآور'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (v11State.reminderLogs.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'یادآورهای آماده',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              ...v11State.reminderLogs.map(
                (log) => ListTile(
                  leading: const Icon(
                    Icons.notifications_rounded,
                    color: PatoghTheme.orange,
                  ),
                  title: Text(log.title),
                  subtitle: Text('${log.deliveryLabel} • ${log.audienceLabel}'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _OpportunitiesTab extends StatelessWidget {
  const _OpportunitiesTab();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: v11State,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'موتور فرصت پاتوق',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'مناسبت + تقاضا + فصل + مسابقه + ظرفیت خالی میزبان = پیشنهاد آماده برای ساخت رویداد.',
              style: TextStyle(color: Color(0xFFAAAAAA), height: 1.6),
            ),
            const SizedBox(height: 14),
            ...v11State.opportunities.map(
              (item) => _opportunityCard(context, item),
            ),
            const SizedBox(height: 18),
            const Text(
              'فیدهای ورزشی و فصلی',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...v11State.moments.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.dateLabel,
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'قالب پیشنهادی: ${item.eventTemplateTitle}',
                      style: const TextStyle(
                        color: PatoghTheme.orange,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'میزبان مناسب: ${item.suggestedHostTypes.join('، ')}',
                      style: const TextStyle(
                        color: Color(0xFF858585),
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
    );
  }
}

Widget _occasionCard(CalendarOccasion item) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF181818),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: PatoghTheme.orange),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              item.layer.label,
              style: const TextStyle(fontSize: 9, color: Color(0xFFAAAAAA)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${item.dateLabel} • ${item.calendarSystem}',
          style: const TextStyle(color: PatoghTheme.orange, fontSize: 11),
        ),
        const SizedBox(height: 5),
        Text(
          item.description,
          style: const TextStyle(
            color: Color(0xFFBBBBBB),
            height: 1.5,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'منبع: ${item.sourceLabel} • ${item.certaintyLabel}',
          style: const TextStyle(color: Color(0xFF777777), fontSize: 9),
        ),
      ],
    ),
  );
}

Widget _opportunityCard(BuildContext context, EventOpportunity item) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
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
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              '${item.opportunityScore}/100',
              style: const TextStyle(
                color: PatoghTheme.orange,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          item.reason,
          style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
        ),
        const SizedBox(height: 7),
        Text(
          '${item.locationLabel} • ${item.demandCount} متقاضی • ${item.matchingHosts} میزبان مناسب',
          style: const TextStyle(color: Color(0xFF888888), fontSize: 10),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const CreateEventPage())),
          icon: const Icon(Icons.auto_awesome_rounded),
          label: Text('ساخت از قالب «${item.suggestedTemplate}»'),
        ),
      ],
    ),
  );
}

Future<void> _addPersonalOccasion(BuildContext context) async {
  final title = TextEditingController();
  final date = TextEditingController();
  final type = TextEditingController(text: 'تولد / سالگرد');
  var audience = OccasionAudience.private;
  var suggest = true;
  var notifyAudience = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            title: const Text('مناسبت شخصی جدید'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'عنوان'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: date,
                    decoration: const InputDecoration(
                      labelText: 'تاریخ / توضیح زمان',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: type,
                    decoration: const InputDecoration(labelText: 'نوع مناسبت'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<OccasionAudience>(
                    initialValue: audience,
                    decoration: const InputDecoration(
                      labelText: 'چه کسانی ببینند؟',
                    ),
                    items: OccasionAudience.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setLocalState(() => audience = value);
                    },
                  ),
                  SwitchListTile(
                    value: suggest,
                    onChanged: (value) => setLocalState(() => suggest = value),
                    title: const Text('براساس این مناسبت رویداد پیشنهاد بده'),
                  ),
                  SwitchListTile(
                    value: notifyAudience,
                    onChanged: (value) =>
                        setLocalState(() => notifyAudience = value),
                    title: const Text(
                      'در زمان انتخابی به حلقه مجاز هم یادآوری کن',
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
                  if (title.text.trim().isEmpty || date.text.trim().isEmpty) {
                    return;
                  }
                  await v11State.addPersonalOccasion(
                    title: title.text.trim(),
                    dateLabel: date.text.trim(),
                    occasionType: type.text.trim(),
                    audience: audience,
                    reminderLabels: const [
                      'یک ماه قبل',
                      'یک هفته قبل',
                      'سه روز قبل',
                      'همان روز',
                    ],
                    suggestEvents: suggest,
                    notifyAudience: notifyAudience,
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                child: const Text('ذخیره'),
              ),
            ],
          );
        },
      );
    },
  );

  title.dispose();
  date.dispose();
  type.dispose();
}
