import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

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
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Vazir',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFFD700),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFFDAA520),
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF121212),
          onPrimary: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Color(0xFFFFD700),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
