import 'package:flutter/material.dart';
import 'package:patogh/data/iran_locations.dart';
import 'package:patogh/models/user_profile.dart';
import 'package:patogh/models/user_role.dart';
import 'package:patogh/state/app_state.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController(text: '25');
  String province = 'خراسان رضوی';
  String city = 'مشهد';

  final selectedRoles = <UserRole>{UserRole.participant};
  final selected = <String>{};

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
    'کودک و خانواده',
    'داوطلبانه',
  ];

  @override
  Widget build(BuildContext context) {
    final cities = IranLocations.citiesFor(province);
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
                initialValue: province,
                isExpanded: true,
                items: IranLocations.provinces
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    province = value;
                    city = IranLocations.citiesFor(province).first;
                  });
                },
                decoration: const InputDecoration(labelText: 'استان'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(province),
                initialValue: city,
                isExpanded: true,
                items: cities
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => city = value);
                },
                decoration: const InputDecoration(labelText: 'شهر'),
              ),
              const SizedBox(height: 18),
              const Text(
                'در پاتوق چه نقش‌هایی داری؟',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'شرکت‌کننده نقش پایه است. نقش‌های حرفه‌ای در Production بعد از بررسی ادمین فعال می‌شوند.',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 10,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    const [
                      UserRole.participant,
                      UserRole.venue,
                      UserRole.coordinator,
                      UserRole.organizer,
                    ].map((role) {
                      final active = selectedRoles.contains(role);
                      return FilterChip(
                        label: Text(role.label),
                        selected: active,
                        onSelected: role == UserRole.participant
                            ? null
                            : (_) {
                                setState(() {
                                  active
                                      ? selectedRoles.remove(role)
                                      : selectedRoles.add(role);
                                });
                              },
                      );
                    }).toList(),
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
                  await appState.configureInitialRoles(selectedRoles);
                  await appState.setSelectedLocation(province, city);
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
