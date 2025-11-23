import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true, // recommended
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF60130E), // 🔥 Your theme red
      secondary: Color(0xFF8B3A32),
    ),

    scaffoldBackgroundColor: Colors.grey[100],

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF60130E),
      foregroundColor: Colors.white,
      elevation: 2,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF60130E),
      foregroundColor: Colors.white,
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF60130E), // 🔥 keep same color in dark theme
      secondary: Color(0xFF8B3A32),
    ),

    scaffoldBackgroundColor: Color(0xFF0F0F0F),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF60130E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF60130E),
      foregroundColor: Colors.white,
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Color(0xFF222222),
    ),
  );
}
