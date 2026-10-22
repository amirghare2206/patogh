import 'package:flutter/material.dart';
import 'package:patogh/services/platform_services.dart';
import 'package:patogh/widgets/profile_avatar_picker.dart';
import 'package:patogh/data/iran_locations.dart';
import 'package:patogh/models/user_profile.dart';
import 'package:patogh/models/user_role.dart';
import 'package:patogh/pages/legal_page.dart';
import 'package:patogh/state/app_state.dart';

class ProfileSetupPage extends StatefulWidget {
  final List<String> initialInterests;
  final String personalityType;
  final String leisureStyle;
  final List<String> personalityTags;
  final Map<String, String> personalityAnswers;

  const ProfileSetupPage({
    super.key,
    this.initialInterests = const [],
    this.personalityType = '',
    this.leisureStyle = '',
    this.personalityTags = const [],
    this.personalityAnswers = const {},
  });

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

  String education = '';
  String maritalStatus = '';
  String childrenStatus = '';
  String militaryStatus = '';
  bool acceptedTerms = false;
  bool _saving = false;
  PickedProfileImage? _pickedAvatar;

  final allInterests = const [
    'کافه و دورهمی',
    'گفت‌وگو',
    'کتاب و ادبیات',
    'بازی',
    'ورزش',
    'سفر و طبیعت',
    'فناوری',
    'فیلم و سینما',
    'هنر',
    'خانواده',
    'داوطلبانه',
    'غذا و آشپزی',
    'عکاسی',
    'موسیقی',
    'همدلی',
    'فکری',
    'کاری',
    'آموزشی',
    'محیط زیست',
    'حیوانات',
    'سلامت و آرامش',
    'ساخت و مهارت',
    'زبان‌آموزی',
    'کشف شهر',
    'تئاتر و اجرا',
    'کارآفرینی',
    'سبک زندگی',
    'بازی فکری',
  ];

  @override
  void initState() {
    super.initState();
    selected.addAll(widget.initialInterests);
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (_saving || !acceptedTerms) return;
    setState(() => _saving = true);
    try {
      final name = nameController.text.trim();
      final age = int.tryParse(ageController.text.trim()) ?? 25;
      final avatarUrl = _pickedAvatar == null
          ? ''
          : await PlatformServices.saveProfileAvatar(
              fileName: _pickedAvatar!.fileName,
              bytes: _pickedAvatar!.bytes,
              mimeType: _pickedAvatar!.mimeType,
            );

      await appState.saveProfile(
        UserProfile(
          name: name.isEmpty ? 'کاربر پاتوق' : name,
          age: age,
          city: city,
          interests: selected.toList(),
          avatarUrl: avatarUrl,
          education: education,
          maritalStatus: maritalStatus,
          hasChildren: childrenStatus.isEmpty ? null : childrenStatus == 'بله',
          militaryStatus: militaryStatus,
          personalityType: widget.personalityType,
          leisureStyle: widget.leisureStyle,
          personalityTags: widget.personalityTags,
          personalityAnswers: widget.personalityAnswers,
          showAge: true,
          allowChat: true,
        ),
      );
      await appState.configureInitialRoles(selectedRoles);
      await appState.setSelectedLocation(province, city);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'پروفایل ذخیره نشد. اتصال را بررسی کن و دوباره تلاش کن.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
              ProfileAvatarPicker(
                previewBytes: _pickedAvatar?.bytes,
                enabled: !_saving,
                onPicked: (picked) => setState(() => _pickedAvatar = picked),
              ),
              const SizedBox(height: 20),
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
                'اطلاعات تکمیلی (اختیاری)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'این اطلاعات برای پیشنهاد مرتبط‌تر استفاده می‌شود. می‌توانی هر مورد را بی‌پاسخ بگذاری.',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 11,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: education,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'تحصیلات (اختیاری)',
                ),
                items: const [
                  DropdownMenuItem(
                    value: '',
                    child: Text('ترجیح می‌دهم نگویم'),
                  ),
                  DropdownMenuItem(value: 'دیپلم', child: Text('دیپلم')),
                  DropdownMenuItem(value: 'کاردانی', child: Text('کاردانی')),
                  DropdownMenuItem(value: 'کارشناسی', child: Text('کارشناسی')),
                  DropdownMenuItem(
                    value: 'کارشناسی ارشد',
                    child: Text('کارشناسی ارشد'),
                  ),
                  DropdownMenuItem(value: 'دکتری', child: Text('دکتری')),
                ],
                onChanged: (value) => setState(() => education = value ?? ''),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: maritalStatus,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'وضعیت تأهل (اختیاری)',
                ),
                items: const [
                  DropdownMenuItem(
                    value: '',
                    child: Text('ترجیح می‌دهم نگویم'),
                  ),
                  DropdownMenuItem(value: 'مجرد', child: Text('مجرد')),
                  DropdownMenuItem(value: 'متأهل', child: Text('متأهل')),
                  DropdownMenuItem(value: 'سایر', child: Text('سایر')),
                ],
                onChanged: (value) =>
                    setState(() => maritalStatus = value ?? ''),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: childrenStatus,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'وضعیت فرزند (اختیاری)',
                ),
                items: const [
                  DropdownMenuItem(
                    value: '',
                    child: Text('ترجیح می‌دهم نگویم'),
                  ),
                  DropdownMenuItem(value: 'بله', child: Text('فرزند دارم')),
                  DropdownMenuItem(value: 'خیر', child: Text('فرزند ندارم')),
                ],
                onChanged: (value) =>
                    setState(() => childrenStatus = value ?? ''),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: militaryStatus,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'وضعیت سربازی (اختیاری)',
                ),
                items: const [
                  DropdownMenuItem(
                    value: '',
                    child: Text('ترجیح می‌دهم نگویم / شامل من نمی‌شود'),
                  ),
                  DropdownMenuItem(
                    value: 'انجام شده',
                    child: Text('انجام شده'),
                  ),
                  DropdownMenuItem(value: 'معاف', child: Text('معاف')),
                  DropdownMenuItem(
                    value: 'در حال انجام',
                    child: Text('در حال انجام'),
                  ),
                  DropdownMenuItem(value: 'مشمول', child: Text('مشمول')),
                ],
                onChanged: (value) =>
                    setState(() => militaryStatus = value ?? ''),
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
              const SizedBox(height: 18),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: acceptedTerms,
                onChanged: (value) =>
                    setState(() => acceptedTerms = value ?? false),
                title: const Text(
                  'شرایط استفاده، سیاست حریم خصوصی و قواعد جامعه پاتوق را می‌پذیرم.',
                  style: TextStyle(fontSize: 11),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              Wrap(
                spacing: 6,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LegalPage(
                          title: 'شرایط استفاده',
                          body: LegalPage.terms,
                        ),
                      ),
                    ),
                    child: const Text('شرایط استفاده'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LegalPage(
                          title: 'سیاست حریم خصوصی',
                          body: LegalPage.privacy,
                        ),
                      ),
                    ),
                    child: const Text('حریم خصوصی'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: acceptedTerms && !_saving ? _completeSetup : null,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('ذخیره و ادامه'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
