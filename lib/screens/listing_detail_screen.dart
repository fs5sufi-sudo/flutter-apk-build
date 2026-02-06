import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/listing.dart';
import 'full_screen_gallery.dart';
import 'agent_profile_screen.dart'; // ایمپورت صفحه پروفایل

class ListingDetailScreen extends StatefulWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> allImages = [];
    if (widget.listing.imageUrl != null) allImages.add(widget.listing.imageUrl!);
    for (var g in widget.listing.gallery) {
      allImages.add(g.imageUrl);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listing.title),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- بخش گالری ---
                  if (allImages.isNotEmpty)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenGallery(
                                  images: allImages,
                                  initialIndex: _currentImageIndex,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            color: Colors.black,
                            child: CarouselSlider(
                              carouselController: _carouselController,
                              options: CarouselOptions(
                                height: 400.0,
                                enlargeCenterPage: false,
                                autoPlay: false,
                                viewportFraction: 1.0,
                                enableInfiniteScroll: false,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                              ),
                              items: allImages.map((imgUrl) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Image.network(
                                        imgUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.error, color: Colors.white),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1} / ${allImages.length}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        if (_currentImageIndex > 0)
                          Positioned(
                            left: 10,
                            child: CircleAvatar(
                              backgroundColor: Colors.black45,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
                                onPressed: () => _carouselController.previousPage(),
                              ),
                            ),
                          ),
                        if (_currentImageIndex < allImages.length - 1)
                          Positioned(
                            right: 10,
                            child: CircleAvatar(
                              backgroundColor: Colors.black45,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
                                onPressed: () => _carouselController.nextPage(),
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, size: 100, color: Colors.white),
                    ),
                  
                  // --- بخش اطلاعات ---
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.listing.price != null
                                  ? '${widget.listing.price} تومان'
                                  : 'قیمت توافقی',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.blue.shade100, borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                  widget.listing.transactionType == 'SA' ? 'فروش' : 'اجاره',
                                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(widget.listing.city, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 32),
                            const Icon(Icons.square_foot, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('${widget.listing.area} متر', style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                        const Divider(height: 32),
                        const Text('توضیحات:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(widget.listing.description, style: const TextStyle(fontSize: 16, height: 1.6)),
                        
                        const SizedBox(height: 32),

                        // --- دکمه مشاهده پروفایل مشاور (جدید) ---
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AgentProfileScreen(agentId: widget.listing.agentId),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blueGrey.shade100,
                                  child: const Icon(Icons.person, color: Colors.blueGrey),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'مشاهده پروفایل مشاور',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        // ---------------------------------------

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(content: Text('تماس با مشاور...')));
                            },
                            icon: const Icon(Icons.phone),
                            label: const Text('تماس با مشاور', style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green, foregroundColor: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
