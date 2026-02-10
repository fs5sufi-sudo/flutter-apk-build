import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController(); // ✅ فیلد جدید
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = await AuthService().getUserProfile();
    if (user != null) {
      setState(() {
        _usernameController.text = user.username;
        _emailController.text = user.email;
      });
    }
  }

  void _updateInfo() async {
    setState(() => _isLoading = true);
    final result = await ApiService().updateAccountInfo(
      _usernameController.text, 
      _emailController.text
    );
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        )
      );
    }
  }

  void _changePassword() async {
    if (_oldPassController.text.isEmpty || _newPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفاً همه فیلدها را پر کنید')));
      return;
    }

    // ✅ اعتبارسنجی تکرار رمز
    if (_newPassController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تکرار رمز عبور مطابقت ندارد'), backgroundColor: Colors.red));
      return;
    }

    if (_newPassController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رمز عبور باید حداقل ۶ کاراکتر باشد'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiService().changePassword(
      _oldPassController.text, 
      _newPassController.text
    );
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        )
      );
      if (result['success']) {
        _oldPassController.clear();
        _newPassController.clear();
        _confirmPassController.clear();
      }
    }
  }

  void _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف حساب کاربری', textAlign: TextAlign.right, style: TextStyle(color: Colors.red)),
        content: const Text(
          'آیا مطمئن هستید؟ این عمل غیرقابل بازگشت است.',
          textAlign: TextAlign.right
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('لغو')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('بله، حذف کن', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await ApiService().deleteAccount();
      if (success) {
        await AuthService().logout();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حساب شما حذف شد')));
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در حذف حساب')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("تنظیمات حساب", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("اطلاعات کاربری"),
                    _buildContainer([
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: "نام کاربری", prefixIcon: Icon(Icons.person_outline), border: InputBorder.none),
                      ),
                      const Divider(),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: "ایمیل", prefixIcon: Icon(Icons.email_outlined), border: InputBorder.none),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(onPressed: _updateInfo, child: const Text("ذخیره تغییرات")),
                      ),
                    ]),

                    const SizedBox(height: 30),
                    _buildSectionTitle("امنیت"),
                    _buildContainer([
                      TextField(
                        controller: _oldPassController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: "رمز عبور فعلی", prefixIcon: Icon(Icons.lock_outline), border: InputBorder.none),
                      ),
                      const Divider(),
                      TextField(
                        controller: _newPassController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: "رمز عبور جدید", prefixIcon: Icon(Icons.key), border: InputBorder.none),
                      ),
                      const Divider(),
                      TextField(
                        controller: _confirmPassController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: "تکرار رمز عبور جدید", prefixIcon: Icon(Icons.check_circle_outline), border: InputBorder.none),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _changePassword, 
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          child: const Text("تغییر رمز عبور")
                        ),
                      ),
                    ]),

                    const SizedBox(height: 30),
                    _buildSectionTitle("منطقه خطر"),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "حذف حساب کاربری تمام اطلاعات شما را پاک می‌کند.",
                            style: TextStyle(color: Colors.red, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _deleteAccount,
                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                            label: const Text("حذف حساب کاربری", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }
}
