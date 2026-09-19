import 'package:flutter/material.dart';
import 'package:patogh/models/ecosystem_models.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/state/app_state.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final titleController = TextEditingController();
  final capacityController = TextEditingController(text: '8');
  final priceController = TextEditingController(text: '250000');
  final minAgeController = TextEditingController(text: '18');
  final maxAgeController = TextEditingController(text: '45');
  final areaController = TextEditingController(text: 'مشهد');
  String category = 'پاتوق آشنایی';
  String geographicLevel = 'شهری';
  String genderPolicy = 'عمومی';
  String attendanceMode = 'بزرگسال';

  @override
  void dispose() {
    titleController.dispose();
    capacityController.dispose();
    priceController.dispose();
    minAgeController.dispose();
    maxAgeController.dispose();
    areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ساخت پاتوق جدید'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان پاتوق',
                  hintText: 'مثلاً قرار شام برنامه‌نویس‌ها',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: category,
                items: appState.categories
                    .where((item) => item.isActive)
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.title,
                        child: Text(item.title),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => category = value);
                },
                decoration: const InputDecoration(labelText: 'دسته‌بندی'),
              ),
              const SizedBox(height: 12),
              const Text(
                'سطح و شرایط حضور',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: geographicLevel,
                items: const ['محلی', 'شهری', 'منطقه‌ای', 'کشوری']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => geographicLevel = value);
                },
                decoration: const InputDecoration(labelText: 'سطح جغرافیایی'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: areaController,
                decoration: const InputDecoration(
                  labelText: 'محدوده جغرافیایی',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minAgeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'حداقل سن'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: maxAgeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'حداکثر سن'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: genderPolicy,
                items: const ['عمومی', 'ویژه بانوان', 'ویژه آقایان', 'خانوادگی']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => genderPolicy = value);
                },
                decoration: const InputDecoration(
                  labelText: 'سیاست جنسیتی / خانوادگی',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: attendanceMode,
                items:
                    const [
                          'بزرگسال',
                          'کودک با والد',
                          'کودک بدون والد با تحویل امن',
                          'خانوادگی',
                          'نوجوان و بزرگسال',
                          'حرفه‌ای',
                        ]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => attendanceMode = value);
                },
                decoration: const InputDecoration(labelText: 'نوع حضور'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ظرفیت'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'قیمت (تومان)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'توضیحات',
                  hintText: 'حال‌وهوای پاتوق، قوانین و برنامه را توضیح بده...',
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: const Text('ارسال برای بررسی / ذخیره پیش‌نویس'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('عنوان پاتوق را وارد کن.')));
      return;
    }

    final now = DateTime.now();
    final id = 'host-${now.microsecondsSinceEpoch}';
    final selectedCategory = appState.categories
        .where((item) => item.title == category)
        .toList();
    final event = PatoghEvent(
      id: id,
      categoryId: selectedCategory.isEmpty
          ? 'intro'
          : selectedCategory.first.id,
      title: title,
      subtitle: category,
      date: 'تاریخ توسط برگزارکننده تعیین می‌شود',
      time: 'ساعت تعیین نشده',
      area: areaController.text.trim().isEmpty
          ? 'مشهد'
          : areaController.text.trim(),
      exactLocationNote: 'آدرس نهایی بعد از تأیید ثبت می‌شود.',
      price: int.tryParse(priceController.text) ?? 0,
      capacity: int.tryParse(capacityController.text) ?? 8,
      reserved: 0,
      womenOnly: genderPolicy == 'ویژه بانوان',
      discounted: false,
      discountPercent: 0,
      description: 'پاتوق ساخته‌شده توسط برگزارکننده و در انتظار بررسی ادمین.',
      participants: const [],
      tags: [category, geographicLevel, genderPolicy],
      gradient: const [Color(0xFF295B6A), Color(0xFF13242A)],
      icon: Icons.groups_rounded,
    );

    await appState.createEvent(event);
    await appState.setEventPolicy(
      EventAudiencePolicy(
        eventId: id,
        geographicLevel: geographicLevel,
        geographicLabel: areaController.text.trim().isEmpty
            ? 'مشهد'
            : areaController.text.trim(),
        minAge: int.tryParse(minAgeController.text) ?? 18,
        maxAge: int.tryParse(maxAgeController.text) ?? 65,
        genderPolicy: genderPolicy,
        attendanceMode: attendanceMode,
        noShowPenalty: 150000,
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'پاتوق ذخیره شد و در نسخه Production برای تأیید ادمین ارسال می‌شود.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }
}
