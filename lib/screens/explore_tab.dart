import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../services/api_service.dart';
import '../utils.dart'; // برای نمایش زمان (مثلاً ۲ ساعت پیش)
// (نکته: فایل listing_detail_screen را بعداً اضافه می‌کنیم، فعلاً کلیک کار نمی‌کند)

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  late Future<List<Listing>> _listingsFuture;

  @override
  void initState() {
    super.initState();
    // دریافت آگهی‌ها از سرور
    _listingsFuture = ApiService().fetchListings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // هدر صفحه (AppBar)
      appBar: AppBar(
        title: const Text(
          "MENSTA",
          style: TextStyle(
            color: Color(0xFFFFD700), // طلایی
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          // دکمه زنگوله
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              // فعلاً فقط پیام می‌دهد
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("بخش اعلان‌ها")),
              );
            },
          ),
        ],
      ),

      // بدنه صفحه (لیست آگهی‌ها)
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: FutureBuilder<List<Listing>>(
          future: _listingsFuture,
          builder: (context, snapshot) {
            // ۱. حالت لودینگ
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
            }
            // ۲. حالت خطا
            if (snapshot.hasError) {
              return Center(child: Text("خطا در دریافت اطلاعات", style: TextStyle(color: Colors.white)));
            }
            // ۳. حالت لیست خالی
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("هنوز آگهی ثبت نشده است", style: TextStyle(color: Colors.white)));
            }

            // ۴. نمایش لیست (گرید ۲ ستونه)
            final listings = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // دو ستون
                childAspectRatio: 0.75, // نسبت ارتفاع به عرض (کشیده)
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                return Card(
                  color: const Color(0xFF1E1E1E), // رنگ کارت تیره
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عکس آگهی
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: listing.imageUrl != null
                              ? Image.network(
                                  listing.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: Colors.grey),
                                )
                              : Container(color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.white54)),
                        ),
                      ),
                      
                      // اطلاعات متنی
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                listing.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                listing.city,
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    listing.price != null ? '${listing.price} ت' : 'توافقی',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700), // قیمت طلایی
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  // قلب (فعلا نمایشی)
                                  const Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
