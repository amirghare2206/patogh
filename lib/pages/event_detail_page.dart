import 'package:flutter/material.dart';
import 'package:patogh/models/patogh_event.dart';

class EventDetailPage extends StatefulWidget {
  final PatoghEvent event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  int selectedTab = 0;
  bool joined = false;

  String _priceText(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        title: const Text(
          'یادآوری پاتوق',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 120),
                  children: [
                    _hero(event),
                    const SizedBox(height: 16),
                    _capacity(event),
                    const SizedBox(height: 16),
                    _infoCard(event),
                    const SizedBox(height: 20),
                    _tabs(),
                    const SizedBox(height: 18),
                    if (selectedTab == 0) _details(event) else _reviews(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _bottomAction(event),
    );
  }

  Widget _hero(PatoghEvent event) {
    return Container(
      height: 245,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: event.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Center(child: Icon(event.icon, color: Colors.white, size: 92)),
          Positioned(
            right: 18,
            top: 18,
            child: _TinyBadge(
              icon: event.womenOnly
                  ? Icons.female_rounded
                  : Icons.groups_rounded,
              text: event.womenOnly ? 'ویژه بانوان' : 'جمع کوچک',
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: Row(
              children: List.generate(
                event.participants.length.clamp(0, 4),
                (index) => Transform.translate(
                  offset: Offset(index * 7.0, 0),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: [
                        const Color(0xFFB96E52),
                        const Color(0xFF566E85),
                        const Color(0xFF806273),
                        const Color(0xFF6A7657),
                      ][index],
                      child: const Icon(
                        Icons.person_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _capacity(PatoghEvent event) {
    return Container(
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: event.full ? const Color(0xFFC8CBD0) : const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(28),
        border: event.full ? null : Border.all(color: const Color(0xFF2B8CC0)),
      ),
      child: Text(
        event.full ? 'تکمیل ظرفیت' : '${event.seatsLeft} صندلی باقی مانده',
        style: TextStyle(
          color: event.full ? const Color(0xFF222222) : Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _infoCard(PatoghEvent event) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF214A5F)),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.location_on_outlined,
            title: 'محل برگزاری',
            value: 'محدوده برگزاری: ${event.area}\n${event.exactLocationNote}',
          ),
          const Divider(height: 28, color: Color(0xFF263B45)),
          _InfoRow(
            icon: Icons.calendar_month_rounded,
            title: 'تاریخ پاتوق',
            value: '${event.date}، ساعت ${event.time}',
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Row(
      children: [
        Expanded(
          child: _DetailTab(
            title: 'جزئیات پاتوق',
            selected: selectedTab == 0,
            onTap: () => setState(() => selectedTab = 0),
          ),
        ),
        Expanded(
          child: _DetailTab(
            title: 'نظر کاربران',
            selected: selectedTab == 1,
            onTap: () => setState(() => selectedTab = 1),
          ),
        ),
      ],
    );
  }

  Widget _details(PatoghEvent event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'درباره این پاتوق:',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          event.description,
          style: const TextStyle(
            color: Color(0xFFE2E2E2),
            height: 1.9,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'یادآوری مهم',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'هنگام مراجعه به محل، شماره رزرو پاتوق خود را به میزبان اعلام کنید. گروه‌بندی‌ها به‌صورت سیستمی انجام می‌شود و بهتر است اعضا قبل از رویداد خارج از پاتوق با هم گروه جداگانه تشکیل ندهند.',
          style: TextStyle(color: Color(0xFFDADADA), height: 1.8, fontSize: 13),
        ),
        const SizedBox(height: 22),
        const Text(
          'شرکت‌کننده‌های این پاتوق:',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            event.participants.length.clamp(0, 4),
            (index) => Padding(
              padding: const EdgeInsets.only(left: 6),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF2B8CC0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: [
                    const Color(0xFFB96E52),
                    const Color(0xFF566E85),
                    const Color(0xFF806273),
                    const Color(0xFF6A7657),
                  ][index],
                  child: const Icon(Icons.person_rounded, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviews() {
    return const Column(
      children: [
        _ReviewCard(
          title: 'تجربه خوب و جمع صمیمی',
          body: 'تعداد کم افراد باعث شد گفت‌وگوها طبیعی‌تر و راحت‌تر پیش بره.',
        ),
        SizedBox(height: 10),
        _ReviewCard(
          title: 'برای آشنایی جدید مناسبه',
          body: 'فضا رسمی نبود و شروع گفت‌وگو هم با چند سؤال ساده راحت شد.',
        ),
      ],
    );
  }

  Widget _bottomAction(PatoghEvent event) {
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          height: 96,
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
                  border: Border.all(color: const Color(0xFF214A5F)),
                ),
                child: Text(
                  '${_priceText(event.price)}\nتومان',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: joined
                      ? null
                      : () {
                          setState(() => joined = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                event.full
                                    ? 'به لیست انتظار اضافه شدی.'
                                    : 'رزرو اولیه ثبت شد.',
                              ),
                            ),
                          );
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A2A),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF6E5A49),
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    joined
                        ? 'ثبت شد'
                        : event.full
                        ? 'لیست انتظار'
                        : 'رزرو پاتوق',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 30, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFFD8D8D8),
                  height: 1.6,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailTab extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _DetailTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? const Color(0xFF2B8CC0)
                  : const Color(0xFF444444),
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

class _TinyBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TinyBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC000000),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String title;
  final String body;

  const _ReviewCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFFCFCFCF),
              height: 1.6,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
