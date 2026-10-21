import 'package:flutter/material.dart';
import 'package:patogh/data/iran_locations.dart';
import 'package:patogh/models/user_profile.dart';
import 'package:patogh/state/app_state.dart';
import 'package:patogh/theme/patogh_theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController nameController;
  late final TextEditingController ageController;
  late String province;
  late String city;
  late Set<String> selectedInterests;
  bool _saving = false;
  String? _error;

  static const List<String> interests = [
    'کافه و دورهمی', 'گفت‌وگو', 'کتاب و ادبیات', 'بازی', 'ورزش',
    'سفر و طبیعت', 'فناوری', 'فیلم و سینما', 'هنر', 'خانواده',
    'داوطلبانه', 'غذا و آشپزی', 'عکاسی', 'موسیقی', 'همدلی', 'فکری',
    'کاری', 'آموزشی', 'محیط زیست', 'حیوانات', 'سلامت و آرامش',
    'ساخت و مهارت', 'زبان‌آموزی', 'کشف شهر', 'تئاتر و اجرا',
    'کارآفرینی', 'سبک زندگی', 'بازی فکری',
  ];

  @override
  void initState() {
    super.initState();
    final profile = appState.profile;
    nameController = TextEditingController(text: profile?.name ?? 'کاربر پاتوق');
    ageController = TextEditingController(text: '${profile?.age ?? 25}');
    const legacyInterestAliases = <String, String>{
      'کافه': 'کافه و دورهمی',
      'کتاب': 'کتاب و ادبیات',
      'سفر': 'سفر و طبیعت',
      'کار': 'کاری',
      'فیلم': 'فیلم و سینما',
    };
    selectedInterests = {
      for (final interest in profile?.interests ?? const <String>[])
        if (interests.contains(legacyInterestAliases[interest] ?? interest))
          legacyInterestAliases[interest] ?? interest,
    };

    final savedCity = profile?.city ?? 'مشهد';
    province = IranLocations.provinces.firstWhere(
      (item) => IranLocations.citiesFor(item).contains(savedCity),
      orElse: () => 'خراسان رضوی',
    );
    final provinceCities = IranLocations.citiesFor(province);
    city = provinceCities.contains(savedCity)
        ? savedCity
        : (provinceCities.isNotEmpty ? provinceCities.first : 'مشهد');
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final age = int.tryParse(ageController.text.trim());
    if (age == null || age < 13 || age > 120) {
      setState(() => _error = 'سن باید عددی بین ۱۳ تا ۱۲۰ باشد.');
      return;
    }
    if (selectedInterests.length < 3) {
      setState(() => _error = 'برای پیشنهادهای بهتر، حداقل ۳ علاقه انتخاب کن.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final current = appState.profile;
      final updated = UserProfile(
        name: nameController.text.trim().isEmpty
            ? 'کاربر پاتوق'
            : nameController.text.trim(),
        age: age,
        city: city,
        interests: selectedInterests.toList()..sort(),
        // Preserve all V14 profile fields while editing basic details.
        education: current?.education ?? '',
        maritalStatus: current?.maritalStatus ?? '',
        hasChildren: current?.hasChildren,
        militaryStatus: current?.militaryStatus ?? '',
        personalityType: current?.personalityType ?? '',
        leisureStyle: current?.leisureStyle ?? '',
        personalityTags: current?.personalityTags ?? const [],
        personalityAnswers: current?.personalityAnswers ?? const {},
        showAge: current?.showAge ?? true,
        allowChat: current?.allowChat ?? true,
        role: current?.role ?? appState.role,
      );

      await appState.saveProfile(updated);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'ذخیره پروفایل انجام نشد. اتصال را بررسی کن و دوباره تلاش کن.\n$error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provinces = IranLocations.provinces;
    final cities = IranLocations.citiesFor(province);
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
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'نام نمایشی'),
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
                items: provinces.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: _saving ? null : (value) {
                  if (value == null) return;
                  final nextCities = IranLocations.citiesFor(value);
                  setState(() {
                    province = value;
                    city = nextCities.isNotEmpty ? nextCities.first : '';
                  });
                },
                decoration: const InputDecoration(labelText: 'استان'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(province),
                initialValue: cities.contains(city) ? city : (cities.isNotEmpty ? cities.first : null),
                isExpanded: true,
                items: cities.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: _saving ? null : (value) {
                  if (value != null) setState(() => city = value);
                },
                decoration: const InputDecoration(labelText: 'شهر'),
              ),
              const SizedBox(height: 18),
              const Text('علایق', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              const Text(
                'حداقل ۳ مورد انتخاب کن. تغییر علایق برای پیشنهادهای آینده استفاده می‌شود.',
                style: TextStyle(color: PatoghTheme.muted, fontSize: 11, height: 1.6),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests.map((interest) {
                  final selected = selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: selected,
                    onSelected: _saving ? null : (value) {
                      setState(() {
                        if (value) {
                          selectedInterests.add(interest);
                        } else {
                          selectedInterests.remove(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Text('انتخاب‌شده: ${selectedInterests.length}', style: const TextStyle(color: PatoghTheme.muted, fontSize: 11)),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF351D22),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.redAccent.withAlpha(100)),
                  ),
                  child: Text(_error!, style: const TextStyle(height: 1.6, fontSize: 11)),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'در حال ذخیره...' : 'ذخیره تغییرات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
