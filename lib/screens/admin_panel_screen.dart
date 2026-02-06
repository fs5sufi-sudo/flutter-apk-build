import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _pendingAgents = [];
  int _freeLimit = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    final agents = await AuthService().getPendingAgents();
    final settings = await AuthService().getSystemSettings();
    setState(() {
      _pendingAgents = agents;
      _freeLimit = settings['free_listings_limit'] ?? 3;
      _isLoading = false;
    });
  }

  void _approve(int id) async {
    await AuthService().approveAgent(id);
    _loadData();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مشاور تأیید شد')));
  }

  void _saveSettings() async {
    await AuthService().updateSystemSettings(_freeLimit);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تنظیمات ذخیره شد')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پنل مدیریت'),
        backgroundColor: const Color(0xFF1E2746),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD4AF37),
          tabs: const [
            Tab(text: 'تأیید مشاوران'),
            Tab(text: 'تنظیمات سیستم'),
          ],
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  // تب ۱: لیست مشاوران
                  _pendingAgents.isEmpty
                      ? const Center(child: Text('هیچ مشاوری منتظر تأیید نیست'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _pendingAgents.length,
                          itemBuilder: (context, index) {
                            final agent = _pendingAgents[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text(agent['username']),
                                subtitle: Text(agent['email']),
                                trailing: ElevatedButton(
                                  onPressed: () => _approve(agent['id']),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                  child: const Text('تأیید'),
                                ),
                              ),
                            );
                          },
                        ),

                  // تب ۲: تنظیمات
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('تعداد آگهی رایگان برای مشاوران:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle, size: 40, color: Colors.red),
                              onPressed: () => setState(() => _freeLimit > 0 ? _freeLimit-- : null),
                            ),
                            const SizedBox(width: 24),
                            Text('$_freeLimit', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF1E2746))),
                            const SizedBox(width: 24),
                            IconButton(
                              icon: const Icon(Icons.add_circle, size: 40, color: Colors.green),
                              onPressed: () => setState(() => _freeLimit++),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveSettings,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
                            child: const Text('ذخیره تنظیمات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
