import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_screen.dart'; // هدایت درست
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    final success = await AuthService().login(_usernameController.text, _passwordController.text);
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        // رفتن به صفحه اصلی و ریست کردن تاریخچه
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ورود موفقیت‌آمیز بود')));
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در ورود')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ورود')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.real_estate_agent, size: 80, color: Color(0xFFFFD700)),
                  const SizedBox(height: 32),
                  TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'نام کاربری')),
                  const SizedBox(height: 16),
                  TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'رمز عبور')),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black),
                    child: _isLoading ? const CircularProgressIndicator() : const Text('ورود'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('حساب ندارید؟ ثبت‌نام کنید', style: TextStyle(color: Colors.white70)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
