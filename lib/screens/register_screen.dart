import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isAgent = false;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  XFile? _avatar;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _avatar = picked);
  }

  Widget _displayAvatar() {
    if (_avatar != null) {
      if (kIsWeb) return Image.network(_avatar!.path, fit: BoxFit.cover);
      return Image.file(File(_avatar!.path), fit: BoxFit.cover);
    }
    return const Icon(Icons.person, size: 60, color: Colors.grey);
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // چک کردن عکس برای مشاور
    if (_isAgent && _avatar == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفاً عکس پروفایل را انتخاب کنید'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    final success = await AuthService().register(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      isAgent: _isAgent,
      phoneNumber: _isAgent ? _phoneController.text : null,
      bio: _isAgent ? _bioController.text : null,
      avatar: _isAgent ? _avatar : null,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        final msg = _isAgent 
            ? 'ثبت‌نام انجام شد. منتظر تأیید مدیر باشید.' 
            : 'ثبت‌نام موفق! وارد شوید.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در ثبت‌نام (نام کاربری تکراری است)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت‌نام کاربر جدید')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_isAgent) ...[
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          child: ClipOval(
                            child: SizedBox(width: 100, height: 100, child: _displayAvatar()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('افزودن عکس پروفایل (اجباری)', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                    ] else ...[
                      const Icon(Icons.person_add, size: 80, color: Colors.blueGrey),
                      const SizedBox(height: 32),
                    ],

                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'نام کاربری (انگلیسی)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                      validator: (v) => v!.isEmpty ? 'الزامی' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'ایمیل', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                      validator: (v) => v!.isEmpty ? 'الزامی' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'رمز عبور', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                      validator: (v) => v!.isEmpty ? 'الزامی' : null,
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      child: SwitchListTile(
                        title: const Text('من مشاور املاک هستم', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('نیاز به تأیید دارد'),
                        value: _isAgent,
                        activeColor: Colors.orange,
                        onChanged: (v) => setState(() => _isAgent = v),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isAgent) ...[
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'شماره تماس', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'برای مشاور الزامی است' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(labelText: 'درباره من', prefixIcon: Icon(Icons.info_outline), border: OutlineInputBorder()),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isAgent ? Colors.orange : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_isAgent ? 'ثبت‌نام مشاور' : 'ثبت‌نام کاربر', style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
