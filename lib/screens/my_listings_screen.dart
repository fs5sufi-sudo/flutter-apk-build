import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../services/api_service.dart';
import '../utils.dart';
import 'edit_listing_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  late Future<List<Listing>> _myListingsFuture;

  @override
  void initState() {
    super.initState();
    _refreshListings();
  }

  void _refreshListings() {
    setState(() {
      _myListingsFuture = ApiService().fetchMyListings();
    });
  }

  void _deleteListing(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف آگهی', textAlign: TextAlign.right),
        content: const Text('آیا مطمئن هستید؟', textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لغو')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService().deleteListing(id);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حذف شد')));
          _refreshListings();
        }
      }
    }
  }

  void _editListing(Listing listing) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditListingScreen(listing: listing)),
    );
    if (result == true) {
      _refreshListings();
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
        title: const Text('آگهی‌های من'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: FutureBuilder<List<Listing>>(
          future: _myListingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('خطا: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('شما هنوز هیچ آگهی ثبت نکرده‌اید.'));
            }

            final listings = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7, // ارتفاع مناسب برای جا شدن دکمه‌های حذف/ویرایش
              ),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      // عکس
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                          child: listing.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                  child: Image.network(
                                    listing.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(Icons.error),
                                  ),
                                )
                              : const Icon(Icons.image),
                        ),
                      ),
                      // اطلاعات و دکمه‌ها
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(listing.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(listing.city, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              // دکمه‌های عملیاتی
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                    onPressed: () => _editListing(listing),
                                    tooltip: 'ویرایش',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                    onPressed: () => _deleteListing(listing.id),
                                    tooltip: 'حذف',
                                  ),
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
