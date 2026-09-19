import 'package:flutter/material.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class PostEventFeedbackPage extends StatefulWidget {
  const PostEventFeedbackPage({super.key});

  @override
  State<PostEventFeedbackPage> createState() => _PostEventFeedbackPageState();
}

class _PostEventFeedbackPageState extends State<PostEventFeedbackPage> {
  PatoghEvent? selectedEvent;
  double eventScore = 4.5;
  double venueScore = 4.5;
  double organizerScore = 4.5;
  double coordinatorScore = 4.5;
  double participantScore = 4.5;
  final TextEditingController positive = TextEditingController();
  final TextEditingController improvement = TextEditingController();

  @override
  void initState() {
    super.initState();
    final eligible = appState.events
        .where((event) => appState.reservedIds.contains(event.id))
        .toList();
    if (eligible.isNotEmpty) {
      selectedEvent = eligible.first;
    } else if (appState.events.isNotEmpty) {
      selectedEvent = appState.events.first;
    }
  }

  @override
  void dispose() {
    positive.dispose();
    improvement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = selectedEvent;
    return Scaffold(
      appBar: AppBar(
        title: const Text('بازخورد بعد از رویداد'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: event == null
          ? const Center(child: Text('رویدادی برای ارزیابی وجود ندارد.'))
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF173026),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_rounded, color: PatoghTheme.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'در Production فقط حضور تأییدشده اجازه ثبت امتیاز دارد.',
                          style: TextStyle(
                            color: Color(0xFFBFE8D2),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: event.id,
                  items: appState.events
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.title),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(
                      () => selectedEvent = appState.events.firstWhere(
                        (item) => item.id == value,
                      ),
                    );
                  },
                  decoration: const InputDecoration(labelText: 'رویداد'),
                ),
                const SizedBox(height: 14),
                _score(
                  'خود رویداد',
                  eventScore,
                  (value) => setState(() => eventScore = value),
                ),
                _score(
                  'میزبان',
                  venueScore,
                  (value) => setState(() => venueScore = value),
                ),
                _score(
                  'برگزارکننده / آژانس',
                  organizerScore,
                  (value) => setState(() => organizerScore = value),
                ),
                _score(
                  'هماهنگ‌کننده',
                  coordinatorScore,
                  (value) => setState(() => coordinatorScore = value),
                ),
                _score(
                  'تعامل شرکت‌کنندگان',
                  participantScore,
                  (value) => setState(() => participantScore = value),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: positive,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'نکته مثبت'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: improvement,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'نکته قابل بهبود',
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('ثبت بازخورد تأییدشده Demo'),
                ),
              ],
            ),
    );
  }

  Widget _score(String label, double value, ValueChanged<double> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  color: PatoghTheme.orange,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 8,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final event = selectedEvent;
    if (event == null) return;
    final comment = [
      positive.text.trim(),
      improvement.text.trim(),
    ].where((item) => item.isNotEmpty).join(' • ');

    await appState.addFeedback(
      eventId: event.id,
      eventTitle: event.title,
      targetTitle: 'خود رویداد',
      targetType: 'رویداد',
      score: eventScore,
      comment: comment.isEmpty ? 'بازخورد ثبت‌شده توسط شرکت‌کننده' : comment,
    );
    await appState.addFeedback(
      eventId: event.id,
      eventTitle: event.title,
      targetTitle: 'کافه روشن',
      targetType: 'میزبان',
      score: venueScore,
      comment: comment.isEmpty ? 'بازخورد میزبان' : comment,
    );
    await appState.addFeedback(
      eventId: event.id,
      eventTitle: event.title,
      targetTitle: 'آژانس تجربه نو',
      targetType: 'برگزارکننده',
      score: organizerScore,
      comment: comment.isEmpty ? 'بازخورد برگزارکننده' : comment,
    );
    await appState.addFeedback(
      eventId: event.id,
      eventTitle: event.title,
      targetTitle: 'مریم رضایی',
      targetType: 'هماهنگ‌کننده',
      score: coordinatorScore,
      comment: comment.isEmpty ? 'بازخورد هماهنگ‌کننده' : comment,
    );
    await appState.addFeedback(
      eventId: event.id,
      eventTitle: event.title,
      targetTitle: 'کاربر پاتوق',
      targetType: 'شرکت‌کننده',
      score: participantScore,
      comment: comment.isEmpty ? 'بازخورد تعامل در جمع' : comment,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('بازخورد ثبت شد و وارد موتور کیفیت پاتوق شد.'),
      ),
    );
    Navigator.of(context).pop();
  }
}
