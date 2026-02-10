import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 رنگ‌های اصلی
  static const Color bgColor = Color(0xFFF6F6FA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1C28);
  static const Color textSecondary = Color(0xFF6E6E7A);
  static const Color textHint = Color(0xFF9A9AA5);
  
  static const Color purpleMain = Color(0xFF7B61FF);
  static const Color purpleLight = Color(0xFF9B7DFF);
  static const Color blueAccent = Color(0xFF5B6CFF);
  static const Color redAccent = Color(0xFFFF4D5A);
  static const Color orangeAccent = Color(0xFFFF8C42);
  static const Color pinkAccent = Color(0xFFFF5A7A);

  // 🌈 گرادیان اصلی دکمه +
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFFFF4D5A),
      Color(0xFFFF7A18),
      Color(0xFFC93AFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🎯 تم اصلی اپ
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: bgColor,
    fontFamily: 'Vazir', 
    useMaterial3: true,
    
    colorScheme: const ColorScheme.light(
      primary: purpleMain,
      secondary: pinkAccent,
      background: bgColor,
      surface: cardColor,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Vazir',
      ),
    ),
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textSecondary),
      bodySmall: TextStyle(color: textHint),
    ),
    
    // بخش cardTheme را حذف کردیم تا خطا ندهد
    // کارت‌ها خودشان رنگ surface را می‌گیرند که تنظیم کردیم
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: purpleMain,
      unselectedItemColor: textSecondary,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: purpleMain,
      foregroundColor: Colors.white,
    ),
  );
}
