import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_tab.dart';
import 'add_listing_screen.dart';
import 'favorites_screen.dart';
import 'my_listings_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;
  bool _isAgent = false;
  bool _isApproved = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    final auth = AuthService();
    final loggedIn = await auth.isLoggedIn();
    bool agent = false;
    bool approved = false;

    if (loggedIn) {
      agent = await auth.isAgent();
      approved = await auth.isUserApproved();
    }

    setState(() {
      _isLoggedIn = loggedIn;
      _isAgent = agent;
      _isApproved = approved;
    });
  }

  // صفحات تب‌ها
  List<Widget> get _pages => [
    const HomeScreen(),
    const SearchTab(),
    const SizedBox(), // جای دکمه وسط
    const FavoritesScreen(),
    _isLoggedIn ? const MyListingsScreen() : const LoginScreen(),
  ];

  void _onTabTapped(int index) async {
    // دکمه وسط (ثبت آگهی)
    if (index == 2) {
      if (!_isLoggedIn) {
        // ۱. اگر مهمان است -> برو لاگین
        _showLoginDialog();
        return;
      }
      
      if (!_isAgent) {
        // ۲. اگر کاربر عادی است -> خطا
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فقط مشاوران می‌توانند آگهی ثبت کنند'), backgroundColor: Colors.red));
        return;
      }

      if (!_isApproved) {
        // ۳. اگر مشاور تایید نشده -> خطا
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حساب شما هنوز تأیید نشده است'), backgroundColor: Colors.orange));
        return;
      }

      // ۴. اگر همه چی اوکی بود -> برو ثبت آگهی
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddListingScreen()));
      return;
    }

    // تب پروفایل
    if (index == 4 && !_isLoggedIn) {
       await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
       _checkStatus(); // بعد از برگشت، وضعیت را آپدیت کن
       if (await AuthService().isLoggedIn()) setState(() => _currentIndex = 4);
       return;
    }

    setState(() => _currentIndex = index);
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('نیاز به ورود'),
        content: const Text('لطفاً وارد شوید.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('لغو')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen())).then((_) => _checkStatus());
            },
            child: const Text('ورود'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'خانه'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'جستجو'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 40, color: Color(0xFFFFD700)), label: 'ثبت'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'علاقه'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'پروفایل'),
        ],
      ),
    );
  }
}
