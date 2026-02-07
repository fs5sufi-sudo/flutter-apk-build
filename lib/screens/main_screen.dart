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
  String? _userAvatarUrl;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    final auth = AuthService();
    final loggedIn = await auth.isLoggedIn();
    String? avatar;
    
    if (loggedIn) {
      final profile = await auth.getProfile();
      if (profile != null) {
        avatar = profile['avatar'];
        // ترفند: اضافه کردن زمان فعلی به ته آدرس برای شکستن کش
        if (avatar != null) {
          avatar = '$avatar?v=${DateTime.now().millisecondsSinceEpoch}';
        }
      }
    }
    
    // شرط مهم: فقط اگر صفحه هنوز باز است آپدیت کن (رفع کرش)
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _userAvatarUrl = avatar;
      });
    }
  }

  List<Widget> get _pages => [
    const HomeScreen(),
    const SearchTab(),
    const SizedBox(), 
    const FavoritesScreen(),
    _isLoggedIn ? const MyListingsScreen() : const LoginScreen(),
  ];

  void _onTabTapped(int index) async {
    if (index == 2) {
      if (!_isLoggedIn) {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        _checkLogin();
      } else {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddListingScreen()));
      }
      return;
    }
    
    if (index == 4 && !_isLoggedIn) {
       await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
       _checkLogin();
       // دوباره چک کن اگر لاگین کرد تب را عوض کن
       if (await AuthService().isLoggedIn()) {
         if (mounted) setState(() => _currentIndex = 4);
       }
       return;
    }
    
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'خانه'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'جستجو'),
          const BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 40, color: Color(0xFFFFD700)), label: 'ثبت'),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'علاقه'),
          
          BottomNavigationBarItem(
            icon: _userAvatarUrl != null
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _currentIndex == 4 ? const Color(0xFFFFD700) : Colors.transparent,
                        width: 2
                      )
                    ),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(_userAvatarUrl!),
                    ),
                  )
                : const Icon(Icons.person),
            label: 'پروفایل',
          ),
        ],
      ),
    );
  }
}
