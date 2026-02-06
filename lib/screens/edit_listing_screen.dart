import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/listing.dart';
import '../services/api_service.dart';

class EditListingScreen extends StatefulWidget {
  final Listing listing;
  const EditListingScreen({super.key, required this.listing});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _cityController;
  late TextEditingController _priceController;
  late TextEditingController _areaController;

  late String _transactionType;
  late String _propertyType;

  XFile? _newMainImage;
  List<XFile> _newGalleryImages = [];
  late List<GalleryImage> _currentGallery;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.listing.title);
    _descController = TextEditingController(text: widget.listing.description);
    _cityController = TextEditingController(text: widget.listing.city);
    _priceController = TextEditingController(text: widget.listing.price ?? '');
    _areaController = TextEditingController(text: widget.listing.area.toString());
    _transactionType = widget.listing.transactionType;
    _propertyType = widget.listing.propertyType;
    _currentGallery = List.from(widget.listing.gallery);
  }

  Future<void> _pickMainImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newMainImage = picked);
    }
  }

  Future<void> _pickGalleryImages() async {
    final List<XFile> pickedList = await _picker.pickMultiImage();
    if (pickedList.isNotEmpty) {
      setState(() {
        _newGalleryImages.addAll(pickedList);
      });
    }
  }

  void _deleteGalleryImage(int index) async {
    final imageId = _currentGallery[index].id;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف عکس'),
        content: const Text('آیا مطمئن هستید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لغو')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await ApiService().deleteGalleryImage(imageId);
      setState(() => _isLoading = false);

      if (success) {
        setState(() => _currentGallery.removeAt(index));
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('عکس حذف شد')));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در حذف')));
      }
    }
  }

  Widget _displayImage(XFile file) {
    if (kIsWeb) {
      return Image.network(file.path, fit: BoxFit.contain);
    } else {
      return Image.file(File(file.path), fit: BoxFit.contain);
    }
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
    if (_priceController.text.isNotEmpty) {
      fields['price'] = _priceController.text;
    }

    final success = await ApiService().updateListing(
      widget.listing.id, 
      fields,
      newMainImage: _newMainImage,
      newGalleryImages: _newGalleryImages,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تغییرات ذخیره شد')));
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در ویرایش')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ویرایش آگهی')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center( // وسط‌چین کردن کل فرم
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // محدود کردن عرض به ۶۰۰ پیکسل
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text('عکس اصلی:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickMainImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.black12, border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                        child: _newMainImage != null
                            ? _displayImage(_newMainImage!)
                            : (widget.listing.imageUrl != null
                                ? Image.network(widget.listing.imageUrl!, fit: BoxFit.contain)
                                : const Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey))),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- گالری ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('گالری تصاویر:', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.add_photo_alternate, color: Colors.blue), onPressed: _pickGalleryImages),
                      ],
                    ),
                    
                    if (_currentGallery.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _currentGallery.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  width: 100,
                                  height: 100,
                                  color: Colors.black12,
                                  child: Image.network(_currentGallery[index].imageUrl, fit: BoxFit.contain),
                                ),
                                Positioned(top: 0, right: 0, child: GestureDetector(onTap: () => _deleteGalleryImage(index), child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)))),
                              ],
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    
                    if (_newGalleryImages.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _newGalleryImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  width: 100,
                                  height: 100,
                                  color: Colors.black12,
                                  child: _displayImage(_newGalleryImages[index]),
                                ),
                                Positioned(
                                  top: 0, right: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _newGalleryImages.removeAt(index)),
                                    child: const CircleAvatar(radius: 10, backgroundColor: Colors.blue, child: Icon(Icons.close, size: 12, color: Colors.white)),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),

                    TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'عنوان', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'الزامی' : null),
                    const SizedBox(height: 16),
                    TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'شهر', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'الزامی' : null),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(child: DropdownButtonFormField<String>(value: _transactionType, items: const [DropdownMenuItem(value: 'SA', child: Text('فروش')), DropdownMenuItem(value: 'RE', child: Text('اجاره'))], onChanged: (v) => setState(() => _transactionType = v!), decoration: const InputDecoration(labelText: 'نوع', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: DropdownButtonFormField<String>(value: _propertyType, items: const [DropdownMenuItem(value: 'AP', child: Text('آپارتمان')), DropdownMenuItem(value: 'VI', child: Text('ویلا')), DropdownMenuItem(value: 'LA', child: Text('زمین'))], onChanged: (v) => setState(() => _propertyType = v!), decoration: const InputDecoration(labelText: 'ملک', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'قیمت', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(controller: _areaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'متراژ', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'الزامی' : null)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(controller: _descController, maxLines: 3, decoration: const InputDecoration(labelText: 'توضیحات', border: OutlineInputBorder())),
                    
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
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
