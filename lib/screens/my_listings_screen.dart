import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../services/api_service.dart';
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

  // ✅ اصلاح شده: اتصال واقعی به سرور
  void _toggleSoldStatus(Listing listing) async {
    String newStatus = (listing.status == 'sold') ? 'active' : 'sold';
    
    // آپدیت سریع UI (Optimistic Update)
    setState(() {
      listing.status = newStatus; 
    });

    final success = await ApiService().updateListingStatus(listing.id, newStatus);
    
    if (!success) {
      // اگر خطا داد برگردان
      setState(() {
        listing.status = (newStatus == 'sold') ? 'active' : 'sold';
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در تغییر وضعیت')));
    } else {
      // اگر موفق بود، لیست را رفرش کن تا مطمئن شویم
      _refreshListings();
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
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1200 ? 5 : screenWidth > 900 ? 4 : screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت آگهی‌های من'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF4F6F8),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: FutureBuilder<List<Listing>>(
          future: _myListingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return const Center(child: Text('خطا در دریافت اطلاعات'));
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('شما هنوز هیچ آگهی ثبت نکرده‌اید.'));

            final listings = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.70, 
              ),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                // بررسی وضعیت از مدل واقعی
                final isSold = listing.status == 'sold';

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: listing.imageUrl != null
                                  ? Image.network(listing.imageUrl!, fit: BoxFit.cover)
                                  : Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                            ),
                            
                            // ✅ نمایش مهر اگر در دیتابیس "sold" باشد
                            if (isSold)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7), // فیلتر سفید
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                child: Center(
                                  child: Transform.rotate(
                                    angle: -0.2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.red, width: 3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        "واگذار شد",
                                        style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(listing.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(
                                isSold ? 'غیرفعال' : (listing.price ?? 'توافقی'), 
                                style: TextStyle(fontSize: 12, color: isSold ? Colors.grey : Colors.blue)
                              ),
                              const Divider(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildIconButton(Icons.edit, Colors.blue, () => _editListing(listing)),
                                  _buildIconButton(
                                    isSold ? Icons.refresh : Icons.check_circle_outline, 
                                    isSold ? Colors.green : Colors.orange, 
                                    () => _toggleSoldStatus(listing) // ارسال کل آبجکت
                                  ),
                                  _buildIconButton(Icons.delete_outline, Colors.red, () => _deleteListing(listing.id)),
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

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
