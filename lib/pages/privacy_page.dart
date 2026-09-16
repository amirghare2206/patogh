import 'package:flutter/material.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool showAge = true;
  bool allowChat = true;
  bool showHistory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حریم خصوصی و اعتماد'),
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
              SwitchListTile(
                value: showAge,
                onChanged: (v) => setState(() => showAge = v),
                title: const Text('نمایش بازه سنی'),
              ),
              SwitchListTile(
                value: allowChat,
                onChanged: (v) => setState(() => allowChat = v),
                title: const Text('اجازه پیام پس از پاتوق'),
              ),
              SwitchListTile(
                value: showHistory,
                onChanged: (v) => setState(() => showHistory = v),
                title: const Text('نمایش سابقه حضور'),
              ),
              const SizedBox(height: 16),
              const Text(
                'اطلاعات حساس کاربران قبل از تکمیل گروه نمایش داده نمی‌شود. گزارش و مسدودسازی کاربران در نسخه نهایی به بک‌اند متصل خواهد شد.',
                style: TextStyle(color: Color(0xFFBDBDBD), height: 1.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
