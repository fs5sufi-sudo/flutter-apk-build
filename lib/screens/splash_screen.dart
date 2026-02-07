import 'package:flutter/material.dart';
import 'main_screen.dart';
import '../services/auth_service.dart'; // اضافه شد

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // تابع جدید برای مدیریت شروع برنامه
  void _initializeApp() async {
    // ۱. ایجاد تاخیر برای نمایش لوگو
    await Future.delayed(const Duration(seconds: 3));

    // ۲. بررسی وضعیت لاگین (اختیاری: اگر بخواهید لاجیک خاصی داشته باشید)
    // فعلاً چون MainScreen خودش لاگین را هندل می‌کند، نیازی به لاجیک پیچیده اینجا نیست
    // اما برای اطمینان از صحت توکن، می‌توانیم اینجا یک چک سریع بزنیم
    final auth = AuthService();
    final isLoggedIn = await auth.isLoggedIn();

    if (mounted) {
      // هدایت به صفحه اصلی
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // مطمئن شوید عکس logo.jpg در assets/images/ هست
            Image.asset(
              'assets/images/logo.jpg', 
              width: 130, 
              height: 130, 
              errorBuilder: (c,e,s) => const Icon(
                Icons.apartment, // آیکون مرتبط‌تر با املاک
                size: 80, 
                color: Color(0xFFFFD700)
              )
            ),
            const SizedBox(height: 20),
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
            const CircularProgressIndicator(color: Color(0xFFFFD700)),
          ],
        ),
      ),
    );
  }
}
