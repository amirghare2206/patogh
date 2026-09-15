import 'package:flutter/material.dart';

void main() {
  runApp(const PatoghApp());
}

class PatoghApp extends StatelessWidget {
  const PatoghApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'پاتوق',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: PatoghHomePage(),
      ),
    );
  }
}

class PatoghHomePage extends StatelessWidget {
  const PatoghHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پاتوق'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              'به پاتوق خوش آمدید',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'نسخه اولیه اپلیکیشن پاتوق',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}