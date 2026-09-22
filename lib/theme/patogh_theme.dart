import 'package:flutter/material.dart';

class PatoghTheme {
  // پالت برند عمومی پاتوق؛ تیره اما شاد تا صفحات قدیمی هم بدون افت خوانایی
  // با هویت بصری جدید سازگار بمانند.
  static const background = Color(0xFF101226);
  static const surface = Color(0xFF191D39);
  static const surface2 = Color(0xFF24294C);
  static const orange = Color(0xFFFF6B35);
  static const teal = Color(0xFF19C4BA);
  static const blue = Color(0xFF39A7FF);
  static const purple = Color(0xFF7C4DFF);
  static const pink = Color(0xFFFF4081);
  static const yellow = Color(0xFFFFC43D);
  static const muted = Color(0xFFB9BDD0);
  static const green = Color(0xFF5ED6A7);

  static const brandGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [orange, pink, purple, teal],
  );

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: orange,
      secondary: teal,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: orange.withAlpha(52),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? orange
                : Colors.white70,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w900
                : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? orange
                : Colors.white70,
          );
        }),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF2D325A),
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        hintStyle: const TextStyle(color: Color(0xFFAEB2C6)),
        prefixIconColor: Colors.white70,
        suffixIconColor: Colors.white70,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFF39416F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFF39416F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: teal, width: 1.7),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF4B527B)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface2,
        selectedColor: orange.withAlpha(58),
        side: const BorderSide(color: Color(0xFF3C426D)),
        labelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerColor: const Color(0xFF30365E),
    );
  }
}
