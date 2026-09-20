import 'package:flutter/material.dart';
import 'package:patogh/config/app_config.dart';
import 'package:patogh/models/v10_models.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/state/v10_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class GolrizonPage extends StatelessWidget {
  const GolrizonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: v10State,
        builder: (context, _) {
          final visible = v10State.golrizons
              .where((campaign) => campaign.status != GolrizonStatus.rejected)
              .toList();

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
                            'گل‌ریزون',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'کمک جمعی شفاف برای یک رویداد، یک نفر یا یک کار خیر',
                            style: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => _createCampaign(context),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF214534), Color(0xFF171717)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.volunteer_activism_rounded,
                        color: PatoghTheme.orange,
                        size: 38,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'پول برای همان هدفی که اعلام شده مصرف می‌شود',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'کمپین‌های عمومی قبل از فعال‌شدن باید توسط ادمین تأیید شوند. برای کمک هزینه حضور در رویداد، مبلغ جمع‌شده به همان رزرو اختصاص پیدا می‌کند و به‌عنوان پول آزاد به شرکت‌کننده پرداخت نمی‌شود.',
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
                ...visible.map((campaign) => _campaignCard(context, campaign)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _campaignCard(BuildContext context, GolrizonCampaign campaign) {
    final formatter = _MoneyFormatter();

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
              Icon(
                campaign.purpose == GolrizonPurpose.eventSeat
                    ? Icons.event_seat_rounded
                    : Icons.favorite_rounded,
                color: PatoghTheme.orange,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  campaign.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              if (campaign.beneficiaryVerified)
                const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF7BE0A8),
                  size: 19,
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            campaign.purpose.label,
            style: const TextStyle(
              color: PatoghTheme.orange,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            campaign.beneficiaryLabel,
            style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
          ),
          if (campaign.eventTitle != null) ...[
            const SizedBox(height: 5),
            Text(
              'رویداد: ${campaign.eventTitle}',
              style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 11),
            ),
          ],
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: campaign.progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(20),
            backgroundColor: const Color(0xFF303030),
            color: PatoghTheme.orange,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${formatter.format(campaign.raisedAmount)} تومان',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Text(
                'از ${formatter.format(campaign.goalAmount)}',
                style: const TextStyle(color: Color(0xFF999999), fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${campaign.contributorCount} مشارکت • ${campaign.deadlineLabel}',
            style: const TextStyle(color: Color(0xFF858585), fontSize: 10),
          ),
          const SizedBox(height: 12),
          if (campaign.status == GolrizonStatus.active)
            FilledButton.icon(
              onPressed: () => _contribute(context, campaign),
              icon: const Icon(Icons.volunteer_activism_rounded),
              label: const Text('مشارکت در گل‌ریزون'),
            )
          else
            OutlinedButton(onPressed: null, child: Text(campaign.status.label)),
        ],
      ),
    );
  }

  Future<void> _createCampaign(BuildContext context) async {
    final title = TextEditingController();
    final beneficiary = TextEditingController();
    final goal = TextEditingController();
    final deadline = TextEditingController();

    var purpose = GolrizonPurpose.eventSeat;
    String? eventId = appState.events.isEmpty ? null : appState.events.first.id;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('گل‌ریزون جدید'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<GolrizonPurpose>(
                      initialValue: purpose,
                      decoration: const InputDecoration(labelText: 'هدف'),
                      items: GolrizonPurpose.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => purpose = value);
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
                      controller: beneficiary,
                      decoration: const InputDecoration(
                        labelText: 'ذی‌نفع / توضیح عمومی',
                      ),
                    ),
                    if (purpose == GolrizonPurpose.eventSeat) ...[
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: eventId,
                        decoration: const InputDecoration(
                          labelText: 'رویداد مقصد',
                        ),
                        items: appState.events
                            .map(
                              (event) => DropdownMenuItem(
                                value: event.id,
                                child: Text(event.title),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setLocalState(() => eventId = value);
                        },
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextField(
                      controller: goal,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'مبلغ هدف (تومان)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: deadline,
                      decoration: const InputDecoration(labelText: 'مهلت'),
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
                    final amount = int.tryParse(goal.text.trim()) ?? 0;
                    if (title.text.trim().isEmpty || amount <= 0) return;

                    final selectedEvent =
                        purpose == GolrizonPurpose.eventSeat && eventId != null
                        ? _eventById(eventId!)
                        : null;

                    await v10State.createGolrizon(
                      title: title.text.trim(),
                      purpose: purpose,
                      beneficiaryLabel: beneficiary.text.trim().isEmpty
                          ? 'ذی‌نفع پس از بررسی ادمین اعلام می‌شود'
                          : beneficiary.text.trim(),
                      goalAmount: amount,
                      deadlineLabel: deadline.text.trim().isEmpty
                          ? 'بدون مهلت مشخص'
                          : deadline.text.trim(),
                      eventId: selectedEvent?.id,
                      eventTitle: selectedEvent?.title,
                    );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('ارسال برای تأیید'),
                ),
              ],
            );
          },
        );
      },
    );

    title.dispose();
    beneficiary.dispose();
    goal.dispose();
    deadline.dispose();
  }

  PatoghEvent? _eventById(String id) {
    for (final event in appState.events) {
      if (event.id == id) return event;
    }
    return null;
  }

  Future<void> _contribute(
    BuildContext context,
    GolrizonCampaign campaign,
  ) async {
    final amount = TextEditingController();
    var anonymous = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('مشارکت'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amount,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'مبلغ (حداکثر ${campaign.remaining} تومان)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: anonymous,
                    onChanged: (value) =>
                        setLocalState(() => anonymous = value),
                    title: const Text('نام من نمایش داده نشود'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('انصراف'),
                ),
                FilledButton(
                  onPressed: AppConfig.isProduction
                      ? null
                      : () async {
                          final value = int.tryParse(amount.text.trim()) ?? 0;
                          if (value <= 0) return;

                          await v10State.contribute(
                            campaignId: campaign.id,
                            contributorLabel:
                                appState.profile?.name ?? 'کاربر پاتوق',
                            amount: value,
                            anonymous: anonymous,
                          );

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                  child: Text(
                    AppConfig.isProduction
                        ? 'پرداخت گل‌ریزون پس از اتصال تسویه امن'
                        : 'پرداخت آزمایشی',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    amount.dispose();
  }
}

class _MoneyFormatter {
  String format(int value) {
    final raw = value.toString();
    final chars = <String>[];

    for (var index = 0; index < raw.length; index++) {
      chars.add(raw[index]);
      final remaining = raw.length - index - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        chars.add(',');
      }
    }

    return chars.join();
  }
}
