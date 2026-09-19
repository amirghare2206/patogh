import 'package:flutter/material.dart';
import 'package:patogh/models/v9_models.dart';
import 'package:patogh/state/v9_state.dart';
import 'package:patogh/state/v10_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class PrivateEventsPage extends StatelessWidget {
  const PrivateEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراسم خصوصی و دعوت‌نامه'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createEvent(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('ساخت مراسم'),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([v9State, v10State]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF35274A), Color(0xFF171717)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.mark_email_read_rounded,
                      color: PatoghTheme.orange,
                      size: 36,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'کارت دعوت دیجیتال پاتوق',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'برای عروسی، تولد، نامزدی، سالگرد، دورهمی خانوادگی، یادبود و مراسم مشابه؛ مهمان را با شماره موبایل، نام کاربری یا حلقه خودت دعوت کن و RSVP را یک‌جا ببین.',
                      style: TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 11,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF171717),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF292929)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: PatoghTheme.orange),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'ساخت و ویرایش پیش‌نویس رایگان است. هزینه خدمات پاتوق هنگام انتشار دعوت‌نامه پرداخت می‌شود و تعرفه آن را ادمین تعیین می‌کند. Boost عمومی فقط با انتخاب خود صاحب مراسم فعال می‌شود.',
                        style: TextStyle(
                          color: Color(0xFFBBBBBB),
                          fontSize: 11,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ...v9State.privateEvents.map(
                (event) => _eventCard(context, event),
              ),
              const SizedBox(height: 8),
              const Text(
                'دعوت‌های اخیر',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...v9State.invitations.map(_invitationCard),
            ],
          );
        },
      ),
    );
  }

  Widget _eventCard(BuildContext context, PrivateEventPlan event) {
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
                  event.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Chip(label: Text(event.eventType)),
            ],
          ),
          const SizedBox(height: 9),
          Text(event.dateLabel),
          const SizedBox(height: 4),
          Text(
            event.locationLabel,
            style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              Chip(label: Text(event.privacyMode)),
              Chip(
                label: Text(
                  '${event.acceptedCount}/${event.invitedCount} تأیید حضور',
                ),
              ),
              if (event.hostCoversHostingCost)
                const Chip(label: Text('هزینه میزبانی با صاحب مراسم')),
            ],
          ),
          const SizedBox(height: 10),
          Builder(
            builder: (context) {
              final publication = v10State.publicationFor(event.id);
              final quote = v10State.quotePrivateEvent(
                inviteCount: event.invitedCount,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          publication.published
                              ? 'منتشر شده • پرداخت ${publication.amountPaid} تومان'
                              : 'هزینه انتشار فعلی از ${quote.total} تومان',
                          style: TextStyle(
                            color: publication.published
                                ? const Color(0xFF7BE0A8)
                                : const Color(0xFFAAAAAA),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (publication.boostEnabled)
                        const Chip(label: Text('Boost')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _inviteGuest(context, event),
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: const Text('دعوت مهمان'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: publication.published
                              ? null
                              : () => _publishEvent(context, event),
                          icon: const Icon(Icons.publish_rounded),
                          label: Text(
                            publication.published
                                ? 'منتشر شده'
                                : 'پرداخت و انتشار',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _invitationCard(EventInvitation invitation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          const Icon(Icons.mail_outline_rounded, color: PatoghTheme.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.invitee,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '${invitation.eventTitle} • ${invitation.deliveryChannel}',
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Chip(label: Text(invitation.status.label)),
        ],
      ),
    );
  }

  Future<void> _createEvent(BuildContext context) async {
    final titleController = TextEditingController();
    final dateController = TextEditingController();
    final locationController = TextEditingController();
    var eventType = 'تولد';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('ساخت مراسم خصوصی'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: eventType,
                      decoration: const InputDecoration(labelText: 'نوع مراسم'),
                      items:
                          const [
                                'تولد',
                                'عروسی',
                                'نامزدی',
                                'سالگرد',
                                'دورهمی خانوادگی',
                                'یادبود / عزا',
                                'فارغ‌التحصیلی',
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
                          setLocalState(() => eventType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان مراسم',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'تاریخ و ساعت',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'محل / توضیح آدرس',
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
                    if (titleController.text.trim().isEmpty) return;
                    await v9State.createPrivateEvent(
                      title: titleController.text.trim(),
                      eventType: eventType,
                      dateLabel: dateController.text.trim().isEmpty
                          ? 'تاریخ تعیین نشده'
                          : dateController.text.trim(),
                      locationLabel: locationController.text.trim().isEmpty
                          ? 'محل بعداً اعلام می‌شود'
                          : locationController.text.trim(),
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

    titleController.dispose();
    dateController.dispose();
    locationController.dispose();
  }

  Future<void> _publishEvent(
    BuildContext context,
    PrivateEventPlan event,
  ) async {
    var includeBoost = false;
    var premiumTemplate = false;
    var sendSms = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            final quote = v10State.quotePrivateEvent(
              inviteCount: event.invitedCount,
              smsCount: sendSms ? event.invitedCount : 0,
              includeBoost: includeBoost,
              premiumTemplate: premiumTemplate,
            );

            return AlertDialog(
              title: const Text('انتشار دعوت‌نامه'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'مراسم خصوصی بدون اجازه شما عمومی نمی‌شود. Boost فقط برای مراسمی استفاده می‌شود که خودتان بخواهید قابلیت معرفی عمومی داشته باشد.',
                      style: TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 11,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: sendSms,
                      onChanged: (value) =>
                          setLocalState(() => sendSms = value),
                      title: const Text('ارسال پیامک دعوت'),
                      subtitle: Text('${event.invitedCount} دعوت ثبت‌شده'),
                    ),
                    SwitchListTile(
                      value: premiumTemplate,
                      onChanged: (value) =>
                          setLocalState(() => premiumTemplate = value),
                      title: const Text('قالب حرفه‌ای دعوت‌نامه'),
                    ),
                    SwitchListTile(
                      value: includeBoost,
                      onChanged: (value) =>
                          setLocalState(() => includeBoost = value),
                      title: const Text('افزایش دیده‌شدن / Boost'),
                      subtitle: const Text('فقط برای مراسم قابل معرفی عمومی'),
                    ),
                    const Divider(height: 24),
                    _priceLine('هزینه پایه', quote.baseFee),
                    _priceLine('دعوت اضافه', quote.extraInviteCost),
                    _priceLine('پیامک', quote.smsCost),
                    _priceLine('قالب حرفه‌ای', quote.premiumTemplateCost),
                    _priceLine('Boost', quote.boostCost),
                    const Divider(height: 24),
                    _priceLine('جمع کل', quote.total, emphasized: true),
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
                    await v10State.payAndPublishPrivateEvent(
                      eventId: event.id,
                      quote: quote,
                      boostEnabled: includeBoost,
                      premiumTemplateEnabled: premiumTemplate,
                    );
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('پرداخت آزمایشی و انتشار'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _priceLine(String title, int amount, {bool emphasized = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: emphasized ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$amount تومان',
            style: TextStyle(
              color: emphasized ? PatoghTheme.orange : Colors.white,
              fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _inviteGuest(
    BuildContext context,
    PrivateEventPlan event,
  ) async {
    final inviteeController = TextEditingController();
    var channel = 'شماره موبایل';
    var plusOneLimit = 0;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('دعوت مهمان'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: channel,
                    decoration: const InputDecoration(labelText: 'روش دعوت'),
                    items: const ['شماره موبایل', 'نام کاربری پاتوق', 'حلقه من']
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setLocalState(() => channel = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: inviteeController,
                    decoration: InputDecoration(
                      labelText: channel == 'شماره موبایل'
                          ? 'شماره موبایل'
                          : channel == 'نام کاربری پاتوق'
                          ? 'نام کاربری'
                          : 'نام فرد / گروه در حلقه',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: plusOneLimit,
                    decoration: const InputDecoration(
                      labelText: 'تعداد همراه مجاز',
                    ),
                    items: const [0, 1, 2, 3]
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text('$item'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setLocalState(() => plusOneLimit = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('انصراف'),
                ),
                FilledButton(
                  onPressed: () async {
                    final invitee = inviteeController.text.trim();
                    if (invitee.isEmpty) return;
                    await v9State.inviteGuest(
                      eventId: event.id,
                      eventTitle: event.title,
                      invitee: invitee,
                      deliveryChannel: channel,
                      plusOneLimit: plusOneLimit,
                    );
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('ارسال دعوت'),
                ),
              ],
            );
          },
        );
      },
    );

    inviteeController.dispose();
  }
}
