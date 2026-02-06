import 'package:flutter/material.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
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
            Image.asset('assets/images/logo.jpg', width: 130, height: 130, errorBuilder: (c,e,s)=>const Icon(Icons.home, size: 80, color: Color(0xFFFFD700))),
            const SizedBox(height: 20),
            const Text("MENSTA", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFFD700), letterSpacing: 4)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Color(0xFFFFD700)),
          ],
        ),
      ),
    );
  }
}
