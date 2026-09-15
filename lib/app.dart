import 'package:flutter/material.dart';
import 'package:patogh/pages/home_page.dart';

class PatoghApp extends StatelessWidget {
  const PatoghApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'پاتوق',
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF276A5B)),
      ),
      home: const PatoghHomePage(),
    );
  }
}
