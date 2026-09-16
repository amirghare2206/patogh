import 'package:flutter/material.dart';
import 'package:patogh/models/user_profile.dart';
import 'package:patogh/state/app_state.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController(text: '25');
  String city = 'مشهد';

  final allInterests = const [
    'کافه',
    'گفت‌وگو',
    'کتاب',
    'بازی',
    'ورزش',
    'سفر',
    'کار',
    'فناوری',
    'فیلم',
    'هنر',
  ];

  final selected = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تکمیل پروفایل')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'نام'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'سن'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: city,
                items: const [
                  DropdownMenuItem(value: 'مشهد', child: Text('مشهد')),
                  DropdownMenuItem(value: 'تهران', child: Text('تهران')),
                  DropdownMenuItem(value: 'اصفهان', child: Text('اصفهان')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => city = value);
                },
                decoration: const InputDecoration(labelText: 'شهر'),
              ),
              const SizedBox(height: 18),
              const Text(
                'علایق',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allInterests.map((interest) {
                  final active = selected.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: active,
                    onSelected: (_) {
                      setState(() {
                        active
                            ? selected.remove(interest)
                            : selected.add(interest);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final age = int.tryParse(ageController.text.trim()) ?? 25;

                  await appState.saveProfile(
                    UserProfile(
                      name: name.isEmpty ? 'کاربر پاتوق' : name,
                      age: age,
                      city: city,
                      interests: selected.toList(),
                      showAge: true,
                      allowChat: true,
                    ),
                  );

                  if (!context.mounted) return;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('ذخیره و ادامه'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
