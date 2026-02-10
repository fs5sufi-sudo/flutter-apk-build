import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/listing.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'full_screen_gallery.dart';
import 'agent_profile_screen.dart'; 
import 'login_screen.dart';

class ListingDetailScreen extends StatefulWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentImageIndex = 0;
  bool _isFavorited = false;
  final ApiService _apiService = ApiService();
  
  List<dynamic> _comments = [];
  bool _isLoadingComments = true;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.listing.isFavorited;
    _apiService.incrementView(widget.listing.id);
    _loadComments();
  }

  void _loadComments() async {
    final comments = await _apiService.getComments(widget.listing.id);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    }
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    final isLoggedIn = await AuthService().isLoggedIn();
    if (!isLoggedIn) {
      if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    final success = await _apiService.addComment(widget.listing.id, _commentController.text);
    if (success) {
      _commentController.clear();
      _loadComments();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نظر شما ثبت شد')));
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در ثبت نظر')));
    }
  }

  void _toggleFavorite() async {
    setState(() => _isFavorited = !_isFavorited);
    final success = await _apiService.toggleFavorite(widget.listing.id);
    if (!success) {
      setState(() => _isFavorited = !_isFavorited);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در ارتباط با سرور')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> allImages = [];
    if (widget.listing.imageUrl != null) allImages.add(widget.listing.imageUrl!);
    for (var g in widget.listing.gallery) {
      allImages.add(g.imageUrl);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // ✅ حل مشکل کیبورد
      appBar: AppBar(
        title: Text(widget.listing.title, style: const TextStyle(fontSize: 16, color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isFavorited ? Icons.favorite : Icons.favorite_border, color: _isFavorited ? Colors.red : Colors.grey),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- اسلایدر ---
                    if (allImages.isNotEmpty)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CarouselSlider(
                            carouselController: _carouselController,
                            options: CarouselOptions(
                              height: 300.0,
                              enlargeCenterPage: false,
                              autoPlay: false,
                              viewportFraction: 1.0,
                              enableInfiniteScroll: allImages.length > 1,
                              onPageChanged: (index, reason) {
                                setState(() => _currentImageIndex = index);
                              },
                            ),
                            items: allImages.map((imgUrl) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenGallery(images: allImages, initialIndex: _currentImageIndex)));
                                },
                                child: Image.network(imgUrl, fit: BoxFit.cover, width: double.infinity, errorBuilder: (c,e,s) => const Icon(Icons.broken_image)),
                              );
                            }).toList(),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
                              child: Text('${_currentImageIndex + 1} / ${allImages.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                          if (allImages.length > 1) ...[
                            Positioned(left: 10, child: CircleAvatar(backgroundColor: Colors.black45, radius: 18, child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white), onPressed: () => _carouselController.previousPage()))),
                            Positioned(right: 10, child: CircleAvatar(backgroundColor: Colors.black45, radius: 18, child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white), onPressed: () => _carouselController.nextPage()))),
                          ]
                        ],
                      )
                    else
                      Container(height: 250, width: double.infinity, color: Colors.grey.shade200, child: const Icon(Icons.image, size: 80, color: Colors.grey)),
                    
                    // --- اطلاعات ---
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: widget.listing.transactionType == 'SA' ? Colors.blue.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                                child: Text(widget.listing.transactionType == 'SA' ? 'فروش' : 'اجاره', style: TextStyle(color: widget.listing.transactionType == 'SA' ? Colors.blue : Colors.green, fontWeight: FontWeight.bold)),
                              ),
                              Text(widget.listing.price != null ? '${widget.listing.price} تومان' : 'قیمت توافقی', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E2746))),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(widget.listing.city, style: const TextStyle(fontSize: 16, color: Colors.black87))),
                              Container(width: 1, height: 20, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 16)),
                              const Icon(Icons.square_foot, color: Colors.grey, size: 20),
                              const SizedBox(width: 8),
                              Text('${widget.listing.area} متر', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
                          const Text('توضیحات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(widget.listing.description, style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87)),
                          const SizedBox(height: 32),
                          
                          // کارت مشاور
                          InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AgentProfileScreen(agentId: widget.listing.agentId))),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                              child: Row(
                                children: [
                                  CircleAvatar(radius: 28, backgroundColor: Colors.grey.shade100, backgroundImage: widget.listing.agentAvatar != null ? NetworkImage(widget.listing.agentAvatar!) : null, child: widget.listing.agentAvatar == null ? const Icon(Icons.person, color: Colors.grey) : null),
                                  const SizedBox(width: 16),
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('مشاور املاک', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), if(widget.listing.agentName != null) Text(widget.listing.agentName!, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // --- لیست نظرات ---
                          const Text('نظرات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          
                          if (_isLoadingComments)
                            const Center(child: CircularProgressIndicator())
                          else if (_comments.isEmpty)
                            const Center(child: Text("هنوز نظری ثبت نشده است.", style: TextStyle(color: Colors.grey)))
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                final comment = _comments[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 16, 
                                        backgroundColor: Colors.grey.shade200,
                                        backgroundImage: comment['user_avatar'] != null ? NetworkImage(comment['user_avatar']) : null,
                                        child: comment['user_avatar'] == null ? const Icon(Icons.person, size: 16, color: Colors.grey) : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(comment['username'] ?? 'کاربر', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                            const SizedBox(height: 4),
                                            Text(comment['text'], style: const TextStyle(fontSize: 14)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          
                          const SizedBox(height: 80), // فضای خالی برای اینکه محتوا زیر باکس پایین نرود
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // --- باکس پایین (تماس + ثبت نظر) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, 
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // فقط به اندازه محتوا جا بگیرد
                children: [
                  // دکمه تماس
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شماره تماس کپی شد'))),
                      icon: const Icon(Icons.call),
                      label: const Text('تماس با آگهی دهنده', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37), 
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // فیلد نظر
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'نظر خود را بنویسید...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _addComment,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
