import 'package:flutter/material.dart';
import 'package:patogh/models/user_profile.dart';
import 'package:patogh/state/app_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController nameController;
  late final TextEditingController ageController;
  late String city;
  late Set<String> selectedInterests;

  final interests = const [
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

  @override
  void initState() {
    super.initState();
    final profile = appState.profile;
    nameController = TextEditingController(
      text: profile?.name ?? 'کاربر پاتوق',
    );
    ageController = TextEditingController(text: '${profile?.age ?? 25}');
    city = profile?.city ?? 'مشهد';
    selectedInterests = {...?profile?.interests};
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = appState.profile;
    final updated = UserProfile(
      name: nameController.text.trim().isEmpty
          ? 'کاربر پاتوق'
          : nameController.text.trim(),
      age: int.tryParse(ageController.text.trim()) ?? 25,
      city: city,
      interests: selectedInterests.toList(),
      showAge: current?.showAge ?? true,
      allowChat: current?.allowChat ?? true,
    );

    await appState.saveProfile(updated);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ویرایش پروفایل'),
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
                  if (value != null) {
                    setState(() => city = value);
                  }
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
                children: interests.map((interest) {
                  return FilterChip(
                    label: Text(interest),
                    selected: selectedInterests.contains(interest),
                    onSelected: (_) {
                      setState(() {
                        if (selectedInterests.contains(interest)) {
                          selectedInterests.remove(interest);
                        } else {
                          selectedInterests.add(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: const Text('ذخیره تغییرات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
