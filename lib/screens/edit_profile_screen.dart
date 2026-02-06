import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isAgent = false; // متغیر برای تشخیص نقش
  
  XFile? _avatar;
  String? _currentAvatarUrl;

  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final profile = await AuthService().getProfile();
    final isAgent = await AuthService().isAgent(); // چک کردن نقش
    
    if (profile != null) {
      setState(() {
        _isAgent = isAgent;
        _phoneController.text = profile['phone_number'] ?? '';
        _bioController.text = profile['bio'] ?? '';
        _currentAvatarUrl = profile['avatar'];
      });
    }
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _avatar = picked);
    }
  }

  Widget _displayAvatar() {
    if (_avatar != null) {
      if (kIsWeb) return Image.network(_avatar!.path, fit: BoxFit.cover);
      return Image.file(File(_avatar!.path), fit: BoxFit.cover);
    } else if (_currentAvatarUrl != null) {
      return Image.network(_currentAvatarUrl!, fit: BoxFit.cover);
    } else {
      return const Icon(Icons.person, size: 60, color: Colors.grey);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final fields = <String, String>{};
    // فقط اگر مشاور باشد، این فیلدها را می‌فرستیم
    if (_isAgent) {
      fields['phone_number'] = _phoneController.text;
      fields['bio'] = _bioController.text;
    }

    final success = await AuthService().updateProfile(fields, _avatar);
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پروفایل به‌روز شد')));
        Navigator.pop(context);
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در بروزرسانی')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ویرایش پروفایل')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // عکس پروفایل (برای همه)
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: SizedBox(
                            width: 120, height: 120,
                            child: _displayAvatar(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('تغییر عکس', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 32),

                    // فیلدها (فقط برای مشاور)
                    if (_isAgent) ...[
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'شماره تماس', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(labelText: 'درباره من (بیوگرافی)', prefixIcon: Icon(Icons.info_outline), border: OutlineInputBorder()),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      const Text("کاربران عادی امکان ویرایش مشخصات تماس را ندارند.", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 32),
                    ],
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ذخیره تغییرات'),
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
