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

  String _transactionType = 'SA';
  String _propertyType = 'AP';

  final ImagePicker _picker = ImagePicker();

  // ... (متدهای pickImage و submitForm تغییری نکرده‌اند - برای خلاصه شدن تکرار نمی‌کنم، اگر خواستید بگویید) ...
  // همان متدهای قبلی را اینجا فرض کنید یا از فایل قبلی کپی کنید.
  // نکته: من برای اطمینان کد کامل submitForm و pickers را می‌گذارم:

  Future<void> _pickMainImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _mainImage = picked);
  }

  Future<void> _pickGalleryImages() async {
    final List<XFile> pickedList = await _picker.pickMultiImage();
    if (pickedList.isNotEmpty) setState(() => _galleryImages.addAll(pickedList));
  }

  Widget _displayImage(XFile file) {
    if (kIsWeb) return Image.network(file.path, fit: BoxFit.contain);
    return Image.file(File(file.path), fit: BoxFit.contain);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final Map<String, String> fields = {
      'title': _titleController.text,
      'description': _descController.text,
      'city': _cityController.text,
      'area': _areaController.text,
      'transaction_type': _transactionType,
      'property_type': _propertyType,
    };
    if (_priceController.text.isNotEmpty) fields['price'] = _priceController.text;

    final success = await ApiService().createListing(fields, _mainImage, _galleryImages);
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('آگهی ثبت شد!')));
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در ثبت.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت آگهی جدید')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // عرض فرم را محدود می‌کنیم
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- انتخاب عکس‌ها ---
                    const Text('عکس اصلی (کاور):', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickMainImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.black12, border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                        child: _mainImage != null
                            ? _displayImage(_mainImage!)
                            : const Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('عکس‌های بیشتر (گالری):', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.add_photo_alternate, color: Colors.blue), onPressed: _pickGalleryImages),
                      ],
                    ),
                    if (_galleryImages.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _galleryImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  width: 100,
                                  height: 100,
                                  color: Colors.black12,
                                  child: _displayImage(_galleryImages[index]),
                                ),
                                Positioned(top: 0, right: 0, child: GestureDetector(onTap: () => setState(() => _galleryImages.removeAt(index)), child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)))),
                              ],
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),

                    // --- فیلدها ---
                    TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'عنوان', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'الزامی' : null),
                    const SizedBox(height: 16),
                    TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'شهر', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'الزامی' : null),
                    const SizedBox(height: 16),
                    
                    Row(children: [
                        Expanded(child: DropdownButtonFormField<String>(value: _transactionType, items: const [DropdownMenuItem(value: 'SA', child: Text('فروش')), DropdownMenuItem(value: 'RE', child: Text('اجاره'))], onChanged: (v) => setState(() => _transactionType = v!), decoration: const InputDecoration(labelText: 'نوع', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: DropdownButtonFormField<String>(value: _propertyType, items: const [DropdownMenuItem(value: 'AP', child: Text('آپارتمان')), DropdownMenuItem(value: 'VI', child: Text('ویلا')), DropdownMenuItem(value: 'LA', child: Text('زمین'))], onChanged: (v) => setState(() => _propertyType = v!), decoration: const InputDecoration(labelText: 'ملک', border: OutlineInputBorder()))),
                      ]),
                    const SizedBox(height: 16),
                    Row(children: [
                        Expanded(child: TextFormField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'قیمت', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(controller: _areaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'متراژ', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'الزامی' : null)),
                      ]),
                    const SizedBox(height: 16),
                    TextFormField(controller: _descController, maxLines: 3, decoration: const InputDecoration(labelText: 'توضیحات', border: OutlineInputBorder())),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _submitForm, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ثبت آگهی'))),
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
