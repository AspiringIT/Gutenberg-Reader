import 'package:flutter/material.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      surface: const Color(0xFFF5F5F5),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      headlineMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
    ),
  );

  static final sepiaTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF4ECD8),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B4636),
      surface: const Color(0xFFF4ECD8),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF5B4636)),
      headlineMedium: TextStyle(color: Color(0xFF5B4636), fontWeight: FontWeight.bold),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
      headlineMedium: TextStyle(color: Color(0xFFE0E0E0), fontWeight: FontWeight.bold),
    ),
  );
}