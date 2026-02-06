import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../services/api_service.dart';
import '../utils.dart';
import 'listing_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Listing>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _refreshFavorites();
  }

  void _refreshFavorites() {
    setState(() {
      _favoritesFuture = ApiService().fetchFavorites();
    });
  }

  void _removeFavorite(Listing listing) async {
    await ApiService().toggleFavorite(listing.id);
    _refreshFavorites();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('از نشان‌شده‌ها حذف شد')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- منطق ریسپانسیو ---
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (screenWidth > 600) crossAxisCount = 3;
    if (screenWidth > 900) crossAxisCount = 4;
    if (screenWidth > 1200) crossAxisCount = 5;
    // ---------------------

    return Scaffold(
      appBar: AppBar(
        title: const Text('نشان‌شده‌ها ❤️'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: FutureBuilder<List<Listing>>(
          future: _favoritesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('خطا: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('شما هیچ آگهی را نشان نکرده‌اید.'));
            }

            final listings = snapshot.data!;
            // استفاده از GridView به جای ListView
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // کارت‌های کشیده و زیبا
              ),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListingDetailScreen(listing: listing),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // عکس
                        Expanded(
                          flex: 4,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: listing.imageUrl != null
                                    ? Image.network(
                                        listing.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Icon(Icons.error),
                                      )
                                    : Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                              ),
                              // دکمه حذف (قلب قرمز) روی عکس
                              Positioned(
                                top: 8,
                                left: 8, // سمت چپ بالا
                                child: GestureDetector(
                                  onTap: () => _removeFavorite(listing),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.favorite, color: Colors.red, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // اطلاعات
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(listing.city, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(listing.price ?? 'توافقی', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                Text(timeAgo(listing.createdAt), style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
