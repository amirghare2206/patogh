import 'package:flutter/material.dart';
import 'package:patogh/models/ecosystem_models.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/pages/booking_builder_page.dart';
import 'package:patogh/pages/reputation_page.dart';
import 'package:patogh/pages/event_memories_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class EventDetailPage extends StatefulWidget {
  final PatoghEvent event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final score = appState.matchScore(event.tags);
    final policy = appState.policyForEvent(event.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات پاتوق'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 130),
            children: [
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(colors: event.gradient),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(event.icon, size: 92, color: Colors.white),
                    ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Chip(label: Text('سازگاری $score٪')),
                    ),
                    if (policy.sponsored)
                      const Positioned(
                        left: 16,
                        top: 16,
                        child: Chip(
                          avatar: Icon(
                            Icons.volunteer_activism_rounded,
                            size: 16,
                          ),
                          label: Text('اسپانسرشده'),
                        ),
                      ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Chip(
                        avatar: const Icon(
                          Icons.local_fire_department_rounded,
                          size: 16,
                        ),
                        label: Text(
                          'محبوبیت ${appState.popularityForEvent(event.id)}٪',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              _audienceChips(policy),
              const SizedBox(height: 14),
              Container(
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: event.isFull
                      ? const Color(0xFFC7CAD0)
                      : const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(28),
                  border: event.isFull
                      ? null
                      : Border.all(color: PatoghTheme.blue),
                ),
                child: Text(
                  event.isFull
                      ? 'تکمیل ظرفیت'
                      : '${event.seatsLeft} صندلی باقی مانده',
                  style: TextStyle(
                    color: event.isFull
                        ? const Color(0xFF222222)
                        : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF214A5F)),
                ),
                child: Column(
                  children: [
                    _row(
                      Icons.location_on_outlined,
                      'محل برگزاری',
                      'محدوده: ${event.area}\n${event.exactLocationNote}',
                    ),
                    const Divider(height: 28, color: Color(0xFF263B45)),
                    _row(
                      Icons.calendar_month_rounded,
                      'تاریخ پاتوق',
                      '${event.date}، ساعت ${event.time}',
                    ),
                  ],
                ),
              ),
              if (policy.sponsored) ...[
                const SizedBox(height: 14),
                _sponsorCard(policy),
              ],
              const SizedBox(height: 16),
              _trustCard(context),
              const SizedBox(height: 12),
              Material(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(20),
                child: ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventMemoriesPage(
                        eventId: event.id,
                        eventTitle: event.title,
                      ),
                    ),
                  ),
                  leading: const Icon(
                    Icons.photo_album_rounded,
                    color: PatoghTheme.orange,
                  ),
                  title: const Text(
                    'خاطرات و آلبوم این رویداد',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: const Text(
                    'عکس، ویدئو، خاطره و یادگاری با دسترسی انتخابی',
                    style: TextStyle(color: Color(0xFF999999), fontSize: 10),
                  ),
                  trailing: const Icon(Icons.chevron_left_rounded),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _tab(
                      'جزئیات',
                      selectedTab == 0,
                      () => setState(() => selectedTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _tab(
                      'بازخورد',
                      selectedTab == 1,
                      () => setState(() => selectedTab = 1),
                    ),
                  ),
                  Expanded(
                    child: _tab(
                      'گفت‌وگو',
                      selectedTab == 2,
                      () => setState(() => selectedTab = 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (selectedTab == 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      event.description,
                      style: const TextStyle(
                        height: 1.9,
                        color: Color(0xFFE1E1E1),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'در مرحله رزرو می‌توانی رزرو فردی/گروهی، فرزند تحت سرپرستی، منوی میزبان و کد تخفیف را تنظیم کنی.',
                      style: TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 11,
                        height: 1.7,
                      ),
                    ),
                  ],
                )
              else if (selectedTab == 1)
                _reviews()
              else
                _discussion(),
            ],
          ),
        ),
      ),
      bottomSheet: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              final reserved = appState.reservedIds.contains(event.id);
              final waitlisted = appState.waitlistIds.contains(event.id);

              return Container(
                height: 100,
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF151515),
                  border: Border(top: BorderSide(color: Color(0xFF252525))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 112,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        policy.sponsored && event.finalPrice == 0
                            ? 'با حمایت\nاسپانسر'
                            : '${event.finalPrice}\nتومان',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: reserved || waitlisted
                            ? null
                            : () async {
                                if (event.isFull) {
                                  await appState.joinWaitlist(event.id);
                                  return;
                                }
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BookingBuilderPage(event: event),
                                  ),
                                );
                                if (mounted) setState(() {});
                              },
                        child: Text(
                          reserved
                              ? 'رزرو شده'
                              : waitlisted
                              ? 'در لیست انتظار'
                              : event.isFull
                              ? 'لیست انتظار'
                              : 'تنظیم و رزرو پاتوق',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _audienceChips(EventAudiencePolicy policy) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        Chip(label: Text(policy.geographicLevel)),
        Chip(label: Text(policy.geographicLabel)),
        Chip(label: Text('${policy.minAge}–${policy.maxAge} سال')),
        Chip(label: Text(policy.genderPolicy)),
      ],
    );
  }

  Widget _sponsorCard(EventAudiencePolicy policy) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF173026),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF285A46)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.volunteer_activism_rounded,
            color: PatoghTheme.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'این رویداد با حمایت ${policy.sponsorName} برگزار می‌شود. شرایط حضور و جریمه No-show قبل از رزرو نمایش داده می‌شود.',
              style: const TextStyle(
                color: Color(0xFFBFE8D2),
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trustCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'اعتبار عوامل این رویداد',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const ReputationPage(reputationId: 'venue-roshan'),
                    ),
                  ),
                  icon: const Icon(Icons.storefront_rounded),
                  label: const Text('میزبان 4.8'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const ReputationPage(reputationId: 'org-novin'),
                    ),
                  ),
                  icon: const Icon(Icons.campaign_rounded),
                  label: const Text('آژانس 4.6'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'امتیازها از تجربه حضور تأییدشده ساخته می‌شوند و کنار ادعاهای پروفایل نمایش داده می‌شوند.',
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 9,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _discussion() {
    final comments = appState.eventComments
        .where((item) => item.eventId == widget.event.id)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _addComment,
          icon: const Icon(Icons.add_comment_rounded),
          label: const Text('سؤال یا نظر درباره این رویداد'),
        ),
        const SizedBox(height: 10),
        if (comments.isEmpty)
          const Text(
            'هنوز گفت‌وگویی شروع نشده.',
            style: TextStyle(color: Color(0xFF999999)),
          )
        else
          ...comments.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 9),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.author,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  Text(item.text, style: const TextStyle(height: 1.6)),
                  const SizedBox(height: 5),
                  Text(
                    item.createdAt,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _addComment() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('نظر یا سؤال'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'درباره رویداد بنویس...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              await appState.addEventComment(widget.event.id, text);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (mounted) setState(() {});
            },
            child: const Text('ارسال'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Widget _reviews() {
    final reviews = appState.feedbackEntries
        .where(
          (item) =>
              item.eventId == widget.event.id || item.targetType == 'رویداد',
        )
        .toList();
    if (reviews.isEmpty) {
      return const Text(
        'هنوز نظر تأییدشده‌ای برای این رویداد ثبت نشده.',
        style: TextStyle(color: Color(0xFFAAAAAA)),
      );
    }
    return Column(
      children: reviews.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFF181818),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: PatoghTheme.green,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  const Expanded(
                    child: Text(
                      'حضور تأییدشده',
                      style: TextStyle(color: PatoghTheme.green, fontSize: 10),
                    ),
                  ),
                  Text(
                    '${item.score}/5',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(item.comment, style: const TextStyle(height: 1.6)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _row(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 30),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text(value, style: const TextStyle(height: 1.6)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tab(String title, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? PatoghTheme.blue : const Color(0xFF444444),
              width: selected ? 3 : 1,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF888888),
            fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
