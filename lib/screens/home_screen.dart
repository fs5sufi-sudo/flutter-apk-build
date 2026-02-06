import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/glass_search_bar.dart';
import 'listing_detail_screen.dart';
import 'login_screen.dart';
import 'add_listing_screen.dart';
import 'my_listings_screen.dart';
import 'favorites_screen.dart';
import 'edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Listing>> _listingsFuture;
  bool _isLoggedIn = false;
  bool _isApproved = false;
  bool _isAgent = false;
  String? _userAvatarUrl;

  String? _filterCity;
  String? _filterType;
  String? _filterMinPrice;
  String? _filterMaxPrice;
  String? _filterTransType;

  int _selectedCategoryIndex = 0;

  final List<Map<String, String>> _categories = [
    {'name': 'همه', 'id': 'all'},
    {'name': 'فروش', 'id': 'sale'},
    {'name': 'اجاره', 'id': 'rent'},
    {'name': 'ویلا', 'id': 'villa'},
    {'name': 'لوکس', 'id': 'luxury'},
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _listingsFuture = ApiService().fetchListings(
        city: _filterCity,
        propertyType: _filterType,
        minPrice: _filterMinPrice,
        maxPrice: _filterMaxPrice,
      );
    });
  }

  void _onCategoryTap(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _filterType = null;
      _filterMinPrice = null;
      _filterTransType = null;

      String id = _categories[index]['id']!;

      if (id == 'sale') {
        _filterTransType = 'SA';
      } else if (id == 'rent') {
        _filterTransType = 'RE';
      } else if (id == 'villa') {
        _filterType = 'VI';
      } else if (id == 'luxury') {
        _filterMinPrice = '10000000000';
      }
      _fetchData();
    });
  }

  Future<void> _checkLoginStatus() async {
    final authService = AuthService();
    final loggedIn = await authService.isLoggedIn();
    
    bool approved = false;
    bool agent = false;
    String? avatar;

    if (loggedIn) {
      approved = await authService.isUserApproved();
      agent = await authService.isAgent();
      final profile = await authService.getProfile();
      if (profile != null) {
        avatar = profile['avatar'];
      }
    }

    setState(() {
      _isLoggedIn = loggedIn;
      _isApproved = approved;
      _isAgent = agent;
      _userAvatarUrl = avatar;
    });
  }

  Future<void> _handleLogout() async {
    await AuthService().logout();
    await _checkLoginStatus();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خروج موفق')));
      _fetchData();
    }
  }

  void _navigateToAddListing() async {
    if (!_isLoggedIn) {
      _showLoginDialog();
      return;
    }
    if (!_isAgent) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فقط مشاوران می‌توانند آگهی ثبت کنند'), backgroundColor: Colors.red));
      return;
    }
    if (!_isApproved) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حساب شما هنوز تأیید نشده است'), backgroundColor: Colors.orange));
      return;
    }
    final result = await Navigator.push(context, MaterialPageRoute(builder: (c) => const AddListingScreen()));
    if (result == true) _fetchData();
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('نیاز به ورود'),
        content: const Text('برای دسترسی باید وارد شوید.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('لغو')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen())).then((_) {
                 _checkLoginStatus();
                 _fetchData();
              });
            },
            child: const Text('ورود'),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(Listing listing) async {
    if (!_isLoggedIn) {
      _showLoginDialog();
      return;
    }
    final success = await ApiService().toggleFavorite(listing.id);
    if (success) {
      _fetchData();
    }
  }

  void _saveSearch(String? city, String? type, String? min, String? max) async {
     if (!_isLoggedIn) {
      _showLoginDialog();
      return;
    }
    final success = await ApiService().createSavedSearch(city: city, propertyType: type, minPrice: min, maxPrice: max);
    if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ثبت شد!'), backgroundColor: Colors.green));
        Navigator.pop(context);
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        String? tempCity = _filterCity;
        String? tempType = _filterType;
        String? tempMin = _filterMinPrice;
        String? tempMax = _filterMaxPrice;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('جستجو و فیلتر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2746))),
                  const SizedBox(height: 20),
                  TextField(decoration: InputDecoration(labelText: 'شهر', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (v) => tempCity = v, controller: TextEditingController(text: _filterCity)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(value: tempType, decoration: InputDecoration(labelText: 'نوع ملک', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: const [DropdownMenuItem(value: null, child: Text('همه')), DropdownMenuItem(value: 'AP', child: Text('آپارتمان')), DropdownMenuItem(value: 'VI', child: Text('ویلا')), DropdownMenuItem(value: 'LA', child: Text('زمین'))], onChanged: (v) => tempType = v),
                  const SizedBox(height: 12),
                  Row(children: [Expanded(child: TextField(decoration: InputDecoration(labelText: 'حداقل قیمت', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number, onChanged: (v) => tempMin = v, controller: TextEditingController(text: _filterMinPrice))), const SizedBox(width: 8), Expanded(child: TextField(decoration: InputDecoration(labelText: 'حداکثر قیمت', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number, onChanged: (v) => tempMax = v, controller: TextEditingController(text: _filterMaxPrice)))]),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _saveSearch(tempCity, tempType, tempMin, tempMax), icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFFD4AF37)), label: const Text('مرا خبر کن'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: const BorderSide(color: Color(0xFFD4AF37)), foregroundColor: const Color(0xFFD4AF37), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                  const SizedBox(height: 12),
                  Row(children: [Expanded(child: TextButton(onPressed: () { setState(() { _filterCity = null; _filterType = null; _filterMinPrice = null; _filterMaxPrice = null; }); _fetchData(); Navigator.pop(context); }, child: const Text('پاک کردن', style: TextStyle(color: Colors.grey)))), const SizedBox(width: 12), Expanded(child: ElevatedButton(onPressed: () { setState(() { _filterCity = tempCity; _filterType = tempType; _filterMinPrice = tempMin; _filterMaxPrice = tempMax; }); _fetchData(); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2746), foregroundColor: const Color(0xFFD4AF37)), child: const Text('جستجو')))]),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProfileMenu() {
    if (!_isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen())).then((_) => _checkLoginStatus());
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: _isAgent ? 250 : 200, 
          child: Column(
            children: [
              ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text('ویرایش پروفایل'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfileScreen())); }),
              if (_isAgent) ListTile(leading: const Icon(Icons.dashboard, color: Colors.orange), title: const Text('مدیریت آگهی‌های من'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (c) => const MyListingsScreen())); }),
              ListTile(leading: const Icon(Icons.favorite, color: Colors.pink), title: const Text('نشان‌ شده‌ها'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (c) => const FavoritesScreen())); }),
              ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('خروج'), onTap: () { Navigator.pop(context); _handleLogout(); }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => _onCategoryTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected ? const LinearGradient(colors: [Color(0xFF1E2746), Color(0xFFD4AF37)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF1E2746).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : null,
              ),
              child: Center(child: Text(_categories[index]['name']!, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold, fontFamily: 'Vazir'))),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    int cols = w > 1200 ? 4 : w > 800 ? 3 : w > 600 ? 2 : 1; 

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: CustomAppBar(
        avatarUrl: _userAvatarUrl,
        onAvatarTap: _showProfileMenu,
        onNotificationTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("نوتیفیکیشن‌ها")));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddListing,
        backgroundColor: const Color(0xFF1E2746), 
        foregroundColor: const Color(0xFFD4AF37),
        icon: const Icon(Icons.add),
        label: const Text("ثبت آگهی"),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: GlassSearchBar(onTap: _showFilterModal)),
            _buildCategoryChips(),
            const SizedBox(height: 8),
            if (_isLoggedIn && _isAgent && !_isApproved)
              Container(width: double.infinity, padding: const EdgeInsets.all(8), color: Colors.orange.shade100, child: const Center(child: Text('حساب شما در انتظار تأیید است', style: TextStyle(color: Colors.red)))),
            
            Expanded(
              child: FutureBuilder<List<Listing>>(
                future: _listingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return Center(child: Text('خطا'));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('آگهی نیست'));

                  final listings = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing))),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 6, 
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      listing.imageUrl != null ? Image.network(listing.imageUrl!, fit: BoxFit.cover) : Container(color: Colors.grey.shade200, child: const Icon(Icons.image, size: 50, color: Colors.grey)),
                                      
                                      // --- عکس مشاور (گوشه چپ بالا) ---
                                      if (listing.agentAvatar != null)
                                        Positioned(
                                          top: 8, left: 8,
                                          child: Container(
                                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                                            child: CircleAvatar(
                                              radius: 22,
                                              backgroundColor: Colors.grey.shade300,
                                              backgroundImage: NetworkImage(listing.agentAvatar!),
                                            ),
                                          ),
                                        ),
                                      // -------------------------------
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(listing.city, style: const TextStyle(color: Colors.grey)),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Text(listing.price ?? 'توافقی', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE76F51))),
                                      
                                      // --- دکمه لایک + زمان ---
                                      Row(
                                        children: [
                                          InkWell(onTap: () => _toggleFavorite(listing), child: Icon(listing.isFavorited ? Icons.favorite : Icons.favorite_border, color: listing.isFavorited ? Colors.red : Colors.grey)),
                                          const SizedBox(width: 8),
                                          Text(timeAgo(listing.createdAt), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                        ],
                                      ),
                                      // -----------------------
                                    ]),
                                  ]),
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
          ],
        ),
      ),
    );
  }
}
