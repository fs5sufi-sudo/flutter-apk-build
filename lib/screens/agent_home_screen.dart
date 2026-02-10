import 'dart:async'; // برای تایمر
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'add_listing_screen.dart';
import 'my_listings_screen.dart';
import 'edit_profile_screen.dart';
import 'subscription_screen.dart';
import 'login_screen.dart';
import 'chat_list_screen.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  int _currentIndex = 0;
  User? _currentUser;
  bool _isLoading = true;
  Timer? _notificationTimer;

  int _totalViews = 0;
  int _remainingCredit = 0;
  int _postCount = 0;
  int _listingCount = 0;
  int _unreadMessages = 0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _startNotificationListener();
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  // ✅ تایمر دقیق مثل HomeScreen
  void _startNotificationListener() {
    _updateUnreadCount(); // اجرای اول
    _notificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateUnreadCount();
    });
  }

  Future<void> _updateUnreadCount() async {
    try {
      final count = await ApiService().getUnreadMessagesCount();
      if (mounted && count != _unreadMessages) {
        setState(() {
          _unreadMessages = count;
        });
      }
    } catch (e) {
      // خطا مهم نیست
    }
  }

  void _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService().getUserProfile();
      final stats = await ApiService().getAgentStats();
      // پیام‌ها را جداگانه در تایمر می‌گیریم، اما اینجا هم یک بار بگیریم بد نیست
      final unread = await ApiService().getUnreadMessagesCount();

      if (mounted) {
        setState(() {
          _currentUser = user;
          _totalViews = stats['total_views'] ?? 0;
          _remainingCredit = stats['remaining_credit'] ?? 0;
          _listingCount = stats['listing_count'] ?? 0;
          _postCount = stats['post_count'] ?? 0;
          _unreadMessages = unread;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اطلاعات به‌روز شد'), duration: Duration(seconds: 1)));
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> pages = [
      _buildDashboardTab(),
      const MyListingsScreen(),
      const ChatListScreen(),
      const EditProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFFF4D5A),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'میز کار'),
            const BottomNavigationBarItem(icon: Icon(Icons.home_work_rounded), label: 'آگهی‌ها'),
            
            // ✅ تب پیام‌ها با Badge
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded),
                  if (_unreadMessages > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          '$_unreadMessages',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              label: 'پیام‌ها',
            ),
            
            const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'پروفایل'),
          ],
        ),
      ),
    );
  }

  // ... (کدهای _buildDashboardTab, _buildStatCard و _buildActionTile تغییری نکرده‌اند و همان قبلی‌ها هستند)
  // برای جلوگیری از طولانی شدن بیش از حد، فقط بخش‌های تغییر یافته را فرستادم.
  // اگر نیاز دارید کل فایل را (شامل بخش‌های UI قبلی) بفرستم، بگویید.
  // اما پیشنهاد می‌کنم فقط متد _startNotificationListener و build را با کدهای بالا جایگزین کنید.
  
  // اگر ترجیح می‌دهید کل فایل را یکجا داشته باشید، لطفاً بگویید "کد کامل کامل".
  Widget _buildDashboardTab() {
    double width = MediaQuery.of(context).size.width;
    int crossAxisCount = width > 900 ? 4 : 2; 
    double aspectRatio = width > 900 ? 1.5 : 1.1;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF4D5A), Color(0xFF7B61FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)),
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white,
                      backgroundImage: _currentUser?.avatar != null ? NetworkImage(_currentUser!.avatar!) : null,
                      child: _currentUser?.avatar == null ? const Icon(Icons.person, size: 35, color: Color(0xFFFF4D5A)) : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "خوش آمدید، ${_currentUser?.username}", 
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            _currentUser?.isApproved == true ? "تأیید شده ✅" : "در انتظار تأیید ⏳",
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadAllData),
                  IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _logout),
                ],
              ),
            ),

            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: aspectRatio,
                            children: [
                              _buildStatCard("بازدید کل", "$_totalViews", Icons.remove_red_eye, Colors.purple),
                              _buildStatCard("اعتبار آگهی", "$_remainingCredit", Icons.account_balance_wallet, Colors.green),
                              _buildStatCard("تعداد ملک", "$_listingCount", Icons.home_filled, Colors.blue),
                              _buildStatCard("پیام جدید", "$_unreadMessages", Icons.chat, Colors.orange),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          const Text("مدیریت سریع", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1C1C28))),
                          const SizedBox(height: 16),

                          _buildActionTile(
                            "ثبت آگهی ملک جدید",
                            "ملک خود را برای فروش یا اجاره ثبت کنید",
                            Icons.add_business_rounded,
                            const Color(0xFF1E2746),
                            () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddListingScreen()));
                              _loadAllData();
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildActionTile(
                            "صندوق پیام‌ها",
                            "مشاهده و پاسخ به پیام‌های کاربران",
                            Icons.chat_bubble_rounded,
                            const Color(0xFFFF4D5A),
                            () async {
                               await Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
                               _loadAllData();
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildActionTile(
                            "خرید بسته افزایش اعتبار",
                            "ارتقای حساب و افزایش بازدید آگهی‌ها",
                            Icons.workspace_premium_rounded,
                            const Color(0xFFD4AF37),
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                          ),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          
          const Spacer(),
          
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value, 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color, fontFamily: 'Vazir')
            ),
          ),
          
          const SizedBox(height: 4),
          
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title, 
              style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withOpacity(0.1), color.withOpacity(0.2)]),
                borderRadius: BorderRadius.circular(16)
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1C1C28))),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
