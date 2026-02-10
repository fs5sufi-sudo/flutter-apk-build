import 'package:flutter/material.dart';
import 'main_screen.dart'; // خانه اصلی
import 'admin_panel_screen.dart'; // پنل ادمین
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _determineRoute();
  }

  void _determineRoute() async {
    // ۱. نمایش لوگو (۳ ثانیه)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final auth = AuthService();
    final isLoggedIn = await auth.isLoggedIn();

    if (isLoggedIn) {
      // اگر لاگین بود، نقش را چک کن
      final role = await auth.getUserRole();
      
      if (role == 'admin') {
        // ادمین مستقیم به پنل مدیریت می‌رود
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
      } 
      else {
        // مشاور و کاربر عادی هر دو به صفحه اصلی می‌روند
        // (مشاور از داخل صفحه اصلی می‌تواند به "میز کار" برود)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      }
    } else {
      // مهمان
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // رنگ پس‌زمینه اسپلش
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // لوگو
            Image.asset(
              'assets/images/logo.jpg', 
              width: 130, 
              height: 130, 
              errorBuilder: (c,e,s) => const Icon(Icons.apartment, size: 80, color: Color(0xFFFFD700))
            ),
            const SizedBox(height: 20),
            // نام اپلیکیشن
            const Text(
              "MENSTA", 
              style: TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: Color(0xFFFFD700), 
                letterSpacing: 4
              )
            ),
            const SizedBox(height: 40),
            // لودینگ
            const CircularProgressIndicator(color: Color(0xFFFFD700)),
          ],
        ),
      ),
    );
  }
}
