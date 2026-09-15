import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3EF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 50,
                color: Color(0xFF276A5B),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'پروفایل',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const Text(
              'اطلاعات حساب کاربری و تنظیمات در این بخش قرار می‌گیرد.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF777777), height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}
