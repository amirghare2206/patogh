import 'package:flutter/material.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/pages/payment_page.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class BookingBuilderPage extends StatefulWidget {
  final PatoghEvent event;

  const BookingBuilderPage({super.key, required this.event});

  @override
  State<BookingBuilderPage> createState() => _BookingBuilderPageState();
}

class _BookingBuilderPageState extends State<BookingBuilderPage> {
  bool groupBooking = false;
  bool includeSelf = true;
  bool acceptedNoShow = false;
  final Set<String> selectedDependents = <String>{};
  final List<String> invitedMembers = <String>[];
  final Map<String, int> quantities = <String, int>{};
  final TextEditingController couponController = TextEditingController();
  int discount = 0;

  @override
  void initState() {
    super.initState();
    final policy = appState.policyForEvent(widget.event.id);
    if (policy.maxAge < 18) includeSelf = false;
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }

  int get seatCount =>
      (includeSelf ? 1 : 0) + selectedDependents.length + invitedMembers.length;

  int get menuTotal {
    var total = 0;
    for (final item in appState.venueMenu) {
      total += item.price * (quantities[item.id] ?? 0);
    }
    return total;
  }

  int get subtotal => widget.event.finalPrice * seatCount + menuTotal;
  int get payable => (subtotal - discount).clamp(0, 1 << 31).toInt();

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final policy = appState.policyForEvent(event.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیم رزرو'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
        children: [
          _summary(event, policy),
          const SizedBox(height: 12),
          _participants(),
          const SizedBox(height: 12),
          _menu(),
          const SizedBox(height: 12),
          _discount(),
          const SizedBox(height: 12),
          _terms(policy),
          const SizedBox(height: 12),
          _invoice(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: FilledButton.icon(
            onPressed:
                acceptedNoShow &&
                    appState.outstandingDebt == 0 &&
                    seatCount > 0 &&
                    (!includeSelf || _selfEligible())
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PaymentPage(
                          event: event,
                          checkoutTotal: payable,
                          checkoutNote: 'رزرو $seatCount نفر + سفارش میزبان',
                        ),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.payment_rounded),
            label: Text(
              appState.outstandingDebt > 0
                  ? 'ابتدا بدهی را تسویه کن'
                  : 'ادامه به پرداخت • $payable تومان',
            ),
          ),
        ),
      ),
    );
  }

  Widget _summary(PatoghEvent event, dynamic policy) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            event.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              Chip(label: Text(policy.geographicLevel)),
              Chip(label: Text('${policy.minAge} تا ${policy.maxAge} سال')),
              Chip(label: Text(policy.genderPolicy)),
              Chip(label: Text(policy.attendanceMode)),
            ],
          ),
          if (policy.sponsored) ...[
            const SizedBox(height: 10),
            Text(
              'این رویداد با حمایت ${policy.sponsorName} برگزار می‌شود. هزینه واقعی صندلی توسط اسپانسر تأمین شده یا یارانه دارد.',
              style: const TextStyle(
                color: PatoghTheme.green,
                height: 1.6,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _participants() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'شرکت‌کننده‌ها',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(child: Text('رزرو گروهی')),
              Switch(
                value: groupBooking,
                onChanged: (value) => setState(() => groupBooking = value),
              ),
            ],
          ),
          const Divider(color: Color(0xFF303030)),
          Row(
            children: [
              Checkbox(
                value: includeSelf,
                onChanged: (value) =>
                    setState(() => includeSelf = value ?? false),
              ),
              const Icon(Icons.person_rounded, color: PatoghTheme.orange),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'خودم',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                _selfEligible() ? 'واجد شرایط سنی' : 'خارج از رده سنی',
                style: TextStyle(
                  color: _selfEligible()
                      ? PatoghTheme.green
                      : const Color(0xFFFF9B9B),
                  fontSize: 9,
                ),
              ),
            ],
          ),
          if (appState.dependents.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'فرزندان / افراد تحت سرپرستی',
              style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 11),
            ),
            const SizedBox(height: 6),
            ...appState.dependents.map(
              (child) => Row(
                children: [
                  Checkbox(
                    value: selectedDependents.contains(child.id),
                    onChanged: _dependentEligible(child.age)
                        ? (value) {
                            setState(() {
                              if (value == true) {
                                selectedDependents.add(child.id);
                              } else {
                                selectedDependents.remove(child.id);
                              }
                            });
                          }
                        : null,
                  ),
                  Expanded(child: Text('${child.name} • ${child.age} سال')),
                  Text(
                    _dependentEligible(child.age)
                        ? 'واجد شرایط'
                        : 'خارج از رده سنی',
                    style: TextStyle(
                      color: _dependentEligible(child.age)
                          ? PatoghTheme.green
                          : const Color(0xFFFF9B9B),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (groupBooking) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _inviteMember,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('دعوت عضو واقعی پاتوق'),
            ),
            if (invitedMembers.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...invitedMembers.map(
                (name) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.hourglass_top_rounded,
                        size: 16,
                        color: Color(0xFFFFC36B),
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(name)),
                      const Text(
                        'دعوت ارسال شد؛ رزرو نهایی پس از تأیید عضو',
                        style: TextStyle(color: Color(0xFF999999), fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  bool _selfEligible() {
    final policy = appState.policyForEvent(widget.event.id);
    final age = appState.profile?.age ?? 25;
    return age >= policy.minAge && age <= policy.maxAge;
  }

  bool _dependentEligible(int age) {
    final policy = appState.policyForEvent(widget.event.id);
    return age >= policy.minAge && age <= policy.maxAge;
  }

  Future<void> _inviteMember() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('دعوت عضو پاتوق'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'نام / شماره عضو'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isEmpty) return;
              setState(() => invitedMembers.add(value));
              Navigator.pop(dialogContext);
            },
            child: const Text('ارسال دعوت'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Widget _menu() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'منوی میزبان برای زمان حضور',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 5),
          const Text(
            'آیتم‌ها همراه رزرو پرداخت و به همان رویداد متصل می‌شوند.',
            style: TextStyle(color: Color(0xFF999999), fontSize: 10),
          ),
          const SizedBox(height: 10),
          ...appState.venueMenu.map((item) {
            final quantity = quantities[item.id] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          item.description,
                          style: const TextStyle(
                            color: Color(0xFF8F8F8F),
                            fontSize: 9,
                          ),
                        ),
                        Text(
                          '${item.price} تومان',
                          style: const TextStyle(
                            color: PatoghTheme.orange,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: quantity > 0
                        ? () =>
                              setState(() => quantities[item.id] = quantity - 1)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => quantities[item.id] = quantity + 1),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _discount() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'کد تخفیف و جشنواره',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: couponController,
                  decoration: const InputDecoration(hintText: 'مثلاً FIRST20'),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  setState(
                    () => discount = appState.calculateDiscount(
                      couponController.text,
                      subtotal,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        discount > 0
                            ? '$discount تومان تخفیف اعمال شد.'
                            : 'کد معتبر نیست یا شامل این رزرو نمی‌شود.',
                      ),
                    ),
                  );
                },
                child: const Text('اعمال'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'کدهای Demo: FIRST20 و GROUP15',
            style: TextStyle(color: Color(0xFF888888), fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _terms(dynamic policy) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF221B16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF5C442E)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFFC36B)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تعهد حضور و قانون No-show',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'در صورت عدم حضور بدون لغو در مهلت مقرر، اعتبار حضور افت جدی می‌کند. برای این رویداد جریمه Demo برابر ${policy.noShowPenalty} تومان است. در رویداد اسپانسری ممکن است هزینه واقعی صندلی نیز بدهی شود و تا تسویه، رزرو جدید مسدود بماند.',
            style: const TextStyle(
              color: Color(0xFFD3C2B3),
              height: 1.7,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Checkbox(
                value: acceptedNoShow,
                onChanged: (value) =>
                    setState(() => acceptedNoShow = value ?? false),
              ),
              const Expanded(
                child: Text(
                  'قوانین حضور، لغو و جریمه را خواندم و می‌پذیرم.',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _invoice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _line('تعداد شرکت‌کننده', '$seatCount نفر'),
          _line('رویداد', '${widget.event.finalPrice * seatCount} تومان'),
          _line('سفارش میزبان', '$menuTotal تومان'),
          _line('تخفیف', '-$discount تومان'),
          const Divider(color: Color(0xFF303030)),
          _line('مبلغ نهایی', '$payable تومان', strong: true),
        ],
      ),
    );
  }

  Widget _line(String label, String value, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: strong ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: strong ? PatoghTheme.orange : Colors.white,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
