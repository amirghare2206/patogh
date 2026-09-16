import 'package:flutter/material.dart';
import 'package:patogh/pages/auth/otp_page.dart';
import 'package:patogh/theme/patogh_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.groups_rounded,
                  size: 76,
                  color: PatoghTheme.orange,
                ),
                const SizedBox(height: 16),
                const Text(
                  'پاتوق',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'آدم‌های تازه، دورهمی‌های واقعی',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFAAAAAA)),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'شماره موبایل',
                    hintText: '09xxxxxxxxx',
                    prefixIcon: Icon(Icons.phone_android_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () {
                    final phone = phoneController.text.trim();
                    if (phone.length < 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('شماره موبایل را کامل وارد کن.'),
                        ),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => OtpPage(phone: phone)),
                    );
                  },
                  child: const Text(
                    'دریافت کد ورود',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'نسخه آزمایشی: کد ورود 1234 است.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF888888), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
