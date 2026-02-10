import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  XFile? _mainImage;
  List<XFile> _galleryImages = [];

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();

  String _transactionType = 'SA'; // فروش
  String _propertyType = 'AP';    // آپارتمان

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMainImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _mainImage = picked);
  }

  Future<void> _pickGalleryImages() async {
    final List<XFile> pickedList = await _picker.pickMultiImage();
    if (pickedList.isNotEmpty) setState(() => _galleryImages.addAll(pickedList));
  }

  Widget _displayImage(XFile file) {
    if (kIsWeb) return Image.network(file.path, fit: BoxFit.cover);
    return Image.file(File(file.path), fit: BoxFit.cover);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    // اعتبارسنجی عکس اصلی
    if (_mainImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفاً عکس اصلی آگهی را انتخاب کنید'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    final Map<String, String> fields = {
      'title': _titleController.text,
      'description': _descController.text,
      'city': _cityController.text,
      'area': _areaController.text,
      'transaction_type': _transactionType,
      'property_type': _propertyType,
      // مقادیر پیش‌فرض برای فیلدهای جدید (هرچند در بک‌اند هم دیفالت دارند)
      'status': 'active', 
      'views_count': '0',
    };
    
    if (_priceController.text.isNotEmpty) {
      fields['price'] = _priceController.text;
    }

    final success = await ApiService().createListing(fields, _mainImage, _galleryImages);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('آگهی با موفقیت ثبت شد!'), backgroundColor: Colors.green));
        Navigator.pop(context, true); // بازگشت با نتیجه موفقیت
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در ثبت آگهی. لطفاً ورودی‌ها را بررسی کنید.'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ثبت آگهی جدید', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- بخش انتخاب عکس ---
                    const Text('تصویر اصلی (کاور):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickMainImage,
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300, width: 1.5, style: BorderStyle.solid),
                        ),
                        child: _mainImage != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(14), child: _displayImage(_mainImage!))
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 50, color: Colors.blue[300]),
                                  const SizedBox(height: 8),
                                  Text("لمس برای افزودن عکس", style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('گالری تصاویر (اختیاری):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        TextButton.icon(
                          onPressed: _pickGalleryImages, 
                          icon: const Icon(Icons.add), 
                          label: const Text("افزودن")
                        ),
                      ],
                    ),
                    
                    if (_galleryImages.isNotEmpty)
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _galleryImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 12),
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: _displayImage(_galleryImages[index]),
                                  ),
                                ),
                                Positioned(
                                  top: 4, right: 4,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _galleryImages.removeAt(index)),
                                    child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 14, color: Colors.white)),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),

                    // --- فیلدهای متنی ---
                    _buildTextField(_titleController, 'عنوان آگهی', Icons.title, maxLines: 1),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_cityController, 'شهر', Icons.location_city)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(_areaController, 'متراژ (متر)', Icons.square_foot, isNumber: true)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(child: _buildDropdown(_transactionType, [
                          const DropdownMenuItem(value: 'SA', child: Text('فروش')),
                          const DropdownMenuItem(value: 'RE', child: Text('اجاره')),
                        ], (v) => setState(() => _transactionType = v!))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDropdown(_propertyType, [
                          const DropdownMenuItem(value: 'AP', child: Text('آپارتمان')),
                          const DropdownMenuItem(value: 'VI', child: Text('ویلا')),
                          const DropdownMenuItem(value: 'LA', child: Text('زمین')),
                        ], (v) => setState(() => _propertyType = v!))),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    _buildTextField(_priceController, 'قیمت (تومان)', Icons.attach_money, isNumber: true, isRequired: false),
                    
                    const SizedBox(height: 16),
                    _buildTextField(_descController, 'توضیحات تکمیلی', Icons.description, maxLines: 4, isRequired: false),
                    
                    const SizedBox(height: 40),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2746), // سرمه‌ای
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 5,
                        ),
                        child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white) 
                            : const Text('ثبت نهایی آگهی', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: isRequired ? (v) => v!.isEmpty ? 'این فیلد الزامی است' : null : null,
    );
  }

  Widget _buildDropdown(String value, List<DropdownMenuItem<String>> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
