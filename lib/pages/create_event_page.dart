import 'package:flutter/material.dart';
import 'package:patogh/models/patogh_event.dart';
import 'package:patogh/state/app_state.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final titleController = TextEditingController();
  final capacityController = TextEditingController(text: '۸');
  final priceController = TextEditingController(text: '250000');
  String category = 'پاتوق آشنایی';

  @override
  void dispose() {
    titleController.dispose();
    capacityController.dispose();
    priceController.dispose();
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
          constraints: const BoxConstraints(maxWidth: 480),
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
                items: const [
                  DropdownMenuItem(
                    value: 'پاتوق آشنایی',
                    child: Text('پاتوق آشنایی'),
                  ),
                  DropdownMenuItem(
                    value: 'پاتوق گفت‌وگو',
                    child: Text('پاتوق گفت‌وگو'),
                  ),
                  DropdownMenuItem(
                    value: 'پاتوق بازی',
                    child: Text('پاتوق بازی'),
                  ),
                  DropdownMenuItem(
                    value: 'پاتوق فکری',
                    child: Text('پاتوق فکری'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => category = value);
                  }
                },
                decoration: const InputDecoration(labelText: 'دسته‌بندی'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ظرفیت'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'قیمت (تومان)'),
              ),
              const SizedBox(height: 12),
              const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'توضیحات',
                  hintText: 'حال‌وهوای پاتوق را توضیح بده...',
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () async {
                  final title = titleController.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('عنوان پاتوق را وارد کن.')),
                    );
                    return;
                  }

                  final now = DateTime.now();
                  final event = PatoghEvent(
                    id: 'host-${now.microsecondsSinceEpoch}',
                    categoryId: 'intro',
                    title: title,
                    subtitle: category,
                    date: 'تاریخ توسط میزبان تعیین می‌شود',
                    time: 'ساعت تعیین نشده',
                    area: 'مشهد',
                    exactLocationNote: 'آدرس نهایی بعداً ثبت می‌شود.',
                    price: int.tryParse(priceController.text) ?? 0,
                    capacity: int.tryParse(capacityController.text) ?? 8,
                    reserved: 0,
                    womenOnly: false,
                    discounted: false,
                    discountPercent: 0,
                    description: 'پاتوق ساخته‌شده توسط میزبان.',
                    participants: const [],
                    tags: const ['میزبان'],
                    gradient: const [Color(0xFF295B6A), Color(0xFF13242A)],
                    icon: Icons.groups_rounded,
                  );

                  await appState.createEvent(event);

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('پاتوق ثبت شد.')),
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.save_rounded),
                label: const Text('ذخیره پیش‌نویس'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
