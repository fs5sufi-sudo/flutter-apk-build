import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'app_theme.dart'; // فایل تم جدید را ایمپورت کردیم

void main() {
  runApp(const MenstaApp());
}

class MenstaApp extends StatelessWidget {
  const MenstaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mensta',
      debugShowCheckedModeBanner: false,
      
      // ✅ استفاده از تم جدید
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // اجبار به استفاده از تم روشن
      
      home: const SplashScreen(),
    );
  }
}
