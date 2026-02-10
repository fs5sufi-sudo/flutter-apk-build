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
        if (avatar != null) {
          avatar = '$avatar?v=${DateTime.now().millisecondsSinceEpoch}';
        }
      }
    }
    
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
    const SizedBox(), // جای خالی برای دکمه وسط
    const FavoritesScreen(),
    _isLoggedIn ? const MyListingsScreen() : const LoginScreen(),
  ];

  void _onTabTapped(int index) async {
    // دکمه وسط (ثبت آگهی)
    if (index == 2) {
      if (!_isLoggedIn) {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        _checkLogin();
      } else {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddListingScreen()));
      }
      return;
    }
    
    // دکمه پروفایل
    if (index == 4 && !_isLoggedIn) {
       await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
       _checkLogin();
       if (await AuthService().isLoggedIn()) {
         if (mounted) setState(() => _currentIndex = 4);
       }
       return;
    }
    
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'خانه'),
            const BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'جستجو'),
            
            // دکمه وسط (ثبت) با استایل گرادیان جذاب
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF4D5A), Color(0xFFC93AFF)], // گرادیان بنفش/قرمز
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x4CFF4D5A),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
              label: '', 
            ),
            
            const BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'علاقه'),
            
            BottomNavigationBarItem(
              icon: _userAvatarUrl != null
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _currentIndex == 4 ? theme.colorScheme.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: NetworkImage(_userAvatarUrl!),
                      ),
                    )
                  : const Icon(Icons.person_rounded),
              label: 'پروفایل',
            ),
          ],
        ),
      ),
    );
  }
}
