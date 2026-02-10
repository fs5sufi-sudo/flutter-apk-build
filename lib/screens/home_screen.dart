import 'dart:async';
import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils.dart'; 
import '../widgets/custom_app_bar.dart';
import 'listing_detail_screen.dart';
import 'login_screen.dart';
import 'add_listing_screen.dart';
import 'my_listings_screen.dart';
import 'favorites_screen.dart';
import 'edit_profile_screen.dart';
import 'admin_panel_screen.dart';
import 'subscription_screen.dart';
import 'agent_home_screen.dart';
import 'settings_screen.dart';
import 'chat_list_screen.dart';

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
  bool _isAdmin = false;
  String? _userAvatarUrl;
  int _unreadCount = 0; // متغیر تعداد پیام
  Timer? _notificationTimer;
  
  String? _filterCity;
  String? _filterType;
  String? _filterMinPrice;
  String? _filterMaxPrice;
  String? _filterTransType;
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'همه', 'id': 'all', 'icon': Icons.home_work_outlined},
    {'name': 'فروش', 'id': 'sale', 'icon': Icons.sell_outlined},
    {'name': 'اجاره', 'id': 'rent', 'icon': Icons.vpn_key_outlined},
    {'name': 'ویلا', 'id': 'villa', 'icon': Icons.villa_outlined},
    {'name': 'لوکس', 'id': 'luxury', 'icon': Icons.star_outline},
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchData();
    _startNotificationListener();
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _startNotificationListener() {
    _notificationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isLoggedIn) {
        _updateUnreadCount();
      }
    });
  }

  Future<void> _updateUnreadCount() async {
    try {
      final count = await ApiService().getUnreadMessagesCount();
      if (mounted && count != _unreadCount) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      // خطا مهم نیست
    }
  }

  void _fetchData() {
    if (!mounted) return;
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
    if (!mounted) return;
    setState(() {
      _selectedCategoryIndex = index;
      _filterType = null;
      _filterMinPrice = null;
      _filterTransType = null;

      String id = _categories[index]['id']!;
      if (id == 'sale') _filterTransType = 'SA';
      else if (id == 'rent') _filterTransType = 'RE';
      else if (id == 'villa') _filterType = 'VI';
      else if (id == 'luxury') _filterMinPrice = '10000000000';
      
      _fetchData();
    });
  }

  Future<void> _checkLoginStatus() async {
    final authService = AuthService();
    final loggedIn = await authService.isLoggedIn();
    
    if (loggedIn) {
      final user = await authService.getUserProfile();
      final unread = await ApiService().getUnreadMessagesCount();

      if (user != null) {
        if (mounted) {
          setState(() {
            _isLoggedIn = true;
            _isApproved = user.isApproved;
            _isAgent = user.isAgent;
            _isAdmin = user.isStaff;
            _userAvatarUrl = user.avatar;
            _unreadCount = unread; // مقدار اولیه
          });
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    await AuthService().logout();
    await _checkLoginStatus();
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _isAgent = false;
        _isAdmin = false;
        _userAvatarUrl = null;
        _unreadCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خروج موفق')));
      _fetchData();
    }
  }

  void _navigateToAddListing() async {
    if (!_isLoggedIn) { _showLoginDialog(); return; }
    if (!_isAgent) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فقط مشاوران می‌توانند آگهی ثبت کنند'), backgroundColor: Colors.red)); return; }
    if (!_isApproved) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حساب شما هنوز تأیید نشده است'), backgroundColor: Colors.orange)); return; }
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
          ElevatedButton(onPressed: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen())).then((_) { _checkLoginStatus(); _fetchData(); }); }, child: const Text('ورود')),
        ],
      ),
    );
  }

  void _toggleFavorite(Listing listing) async {
    if (!_isLoggedIn) { _showLoginDialog(); return; }
    setState(() => listing.isFavorited = !listing.isFavorited);
    final success = await ApiService().toggleFavorite(listing.id);
    if (!success) {
      setState(() => listing.isFavorited = !listing.isFavorited);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در ارتباط با سرور')));
    }
  }

  void _saveSearch(String? city, String? type, String? min, String? max) async {
     if (!_isLoggedIn) { _showLoginDialog(); return; }
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 20),
                  const Text('جستجو و فیلتر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(decoration: InputDecoration(labelText: 'شهر', prefixIcon: const Icon(Icons.location_city), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (v) => tempCity = v, controller: TextEditingController(text: _filterCity)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(value: tempType, decoration: InputDecoration(labelText: 'نوع ملک', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: const [DropdownMenuItem(value: null, child: Text('همه')), DropdownMenuItem(value: 'AP', child: Text('آپارتمان')), DropdownMenuItem(value: 'VI', child: Text('ویلا')), DropdownMenuItem(value: 'LA', child: Text('زمین'))], onChanged: (v) => tempType = v),
                  const SizedBox(height: 12),
                  Row(children: [Expanded(child: TextField(decoration: InputDecoration(labelText: 'حداقل قیمت', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number, onChanged: (v) => tempMin = v, controller: TextEditingController(text: _filterMinPrice))), const SizedBox(width: 8), Expanded(child: TextField(decoration: InputDecoration(labelText: 'حداکثر قیمت', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number, onChanged: (v) => tempMax = v, controller: TextEditingController(text: _filterMaxPrice)))]),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _saveSearch(tempCity, tempType, tempMin, tempMax), icon: const Icon(Icons.notifications_active_outlined), label: const Text('مرا خبر کن'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                  const SizedBox(height: 12),
                  Row(children: [Expanded(child: TextButton(onPressed: () { setState(() { _filterCity = null; _filterType = null; _filterMinPrice = null; _filterMaxPrice = null; }); _fetchData(); Navigator.pop(context); }, child: const Text('پاک کردن', style: TextStyle(color: Colors.grey)))), const SizedBox(width: 12), Expanded(child: ElevatedButton(onPressed: () { setState(() { _filterCity = tempCity; _filterType = tempType; _filterMinPrice = tempMin; _filterMaxPrice = tempMax; }); _fetchData(); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white), child: const Text('جستجو')))]),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isAgent)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2746),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.dashboard_customize, color: Color(0xFFD4AF37)),
                    title: const Text('ورود به میز کار', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const AgentHomeScreen()));
                    },
                  ),
                ),

              ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text('ویرایش پروفایل'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfileScreen())); }),
              
              ListTile(leading: const Icon(Icons.settings, color: Colors.grey), title: const Text('تنظیمات حساب'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsScreen())); }),

              if (_isAdmin) ListTile(leading: const Icon(Icons.settings, color: Colors.black), title: const Text('پنل مدیریت'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminPanelScreen())); }),
              
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
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => _onCategoryTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: Colors.grey.shade200),
                boxShadow: isSelected 
                    ? [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] 
                    : null,
              ),
              child: Row(
                children: [
                  Icon(_categories[index]['icon'], color: isSelected ? Colors.white : Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(_categories[index]['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.grey[800], fontWeight: FontWeight.bold)),
                ],
              ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      appBar: CustomAppBar(
        avatarUrl: _userAvatarUrl,
        onAvatarTap: _showProfileMenu,
        // ✅ دکمه زنگوله به لیست چت هدایت می‌کند و بج دارد
        onNotificationTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen())),
        unreadCount: _unreadCount, // ارسال تعداد به هدر
      ),
      
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: GestureDetector(
                onTap: _showFilterModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text("جستجوی ملک...", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                      const Spacer(),
                      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.tune, color: Theme.of(context).primaryColor, size: 20)),
                    ],
                  ),
                ),
              ),
            ),
            
            _buildCategoryChips(),
            const SizedBox(height: 12),
            
            if (_isLoggedIn && _isAgent && !_isApproved)
              Container(
                width: double.infinity, 
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12), 
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text('حساب شما در انتظار تأیید است', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ],
                )
              ),
            
            Expanded(
              child: FutureBuilder<List<Listing>>(
                future: _listingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return const Center(child: Text('خطا در دریافت اطلاعات'));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('آگهی یافت نشد'));
                  
                  final listings = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols, 
                      crossAxisSpacing: 16, 
                      mainAxisSpacing: 20, 
                      childAspectRatio: 0.75
                    ),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      final isSold = listing.status == 'sold';

                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing))),
                        child: Card(
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.05),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 6,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      listing.imageUrl != null 
                                          ? Image.network(listing.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity) 
                                          : Container(color: Colors.grey.shade100, child: Center(child: Icon(Icons.image, size: 40, color: Colors.grey[300]))),
                                      
                                      if (isSold)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.7),
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          child: Center(
                                            child: Transform.rotate(
                                              angle: -0.2,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.red, width: 2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text("واگذار شد", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                                              ),
                                            ),
                                          ),
                                        ),

                                      Positioned(
                                        top: 10, right: 10,
                                        child: GestureDetector(
                                          onTap: () => _toggleFavorite(listing),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                            child: Icon(
                                              listing.isFavorited ? Icons.favorite : Icons.favorite_border,
                                              color: listing.isFavorited ? Colors.red : Colors.black87,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // عکس مشاور
                                      if (listing.agentAvatar != null)
                                        Positioned(
                                          top: 10, left: 10,
                                          child: Container(
                                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                                            child: CircleAvatar(radius: 16, backgroundColor: Colors.grey.shade300, backgroundImage: NetworkImage(listing.agentAvatar!))
                                          )
                                        ),

                                      if (!isSold) 
                                        Positioned(
                                          bottom: 10, left: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                                            child: Text(listing.transactionType == 'SA' ? 'فروش' : 'اجاره', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        listing.title, 
                                        maxLines: 1, overflow: TextOverflow.ellipsis, 
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1C1C28))
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
                                          const SizedBox(width: 4),
                                          Expanded(child: Text(listing.city, style: TextStyle(color: Colors.grey[500], fontSize: 12), overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isSold ? 'غیرفعال' : (listing.price != null ? "${listing.price} تومان" : "توافقی"), 
                                        style: TextStyle(fontWeight: FontWeight.w900, color: isSold ? Colors.grey : Theme.of(context).primaryColor, fontSize: 16)
                                      ),
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
          ],
        ),
      ),
    );
  }
}
