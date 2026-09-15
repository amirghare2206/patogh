import 'package:flutter/material.dart';
import 'package:patogh/pages/root_shell.dart';

class PatoghApp extends StatelessWidget {
  const PatoghApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF101010);
    const card = Color(0xFF181818);
    const orange = Color(0xFFFF8A2A);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'پاتوق',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: orange,
          secondary: Color(0xFF2A7AA1),
          surface: card,
        ),
        fontFamily: null,
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1B1B1B),
          hintStyle: const TextStyle(color: Color(0xFFB4B4B4)),
          prefixIconColor: const Color(0xFFDFDFDF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Color(0xFF214A5F)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Color(0xFF214A5F)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Color(0xFF2C87B1), width: 1.4),
          ),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const RootShell(),
    );
  }
}
