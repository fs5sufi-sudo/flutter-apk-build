import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/listing.dart';
import '../services/api_service.dart';
import 'listing_detail_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Listing> _searchResults = [];
  bool _isLoading = false;
  Map<String, dynamic>? _activeAd;
  bool _isAdLoading = true;
  String _selectedTransaction = 'SA';

  @override
  void initState() {
    super.initState();
    _loadAd();
    _performSearch();
  }

  Future<void> _loadAd() async {
    final ad = await ApiService().fetchActiveAd();
    if (mounted) setState(() { _activeAd = ad; _isAdLoading = false; });
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    try {
      final results = await ApiService().fetchListings();
      setState(() {
        _searchResults = results;
        _searchResults = _searchResults.where((item) => item.transactionType == _selectedTransaction).toList();
        if (_searchController.text.isNotEmpty) {
          _searchResults = _searchResults.where((item) => item.title.contains(_searchController.text) || item.city.contains(_searchController.text)).toList();
        }
      });
    } catch (e) { print(e); } finally { setState(() => _isLoading = false); }
  }

  Future<void> _launchAdLink() async {
    if (_activeAd != null && _activeAd!['link_url'] != null) {
      final Uri url = Uri.parse(_activeAd!['link_url']);
      if (!await launchUrl(url)) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لینک باز نشد')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800), // محدودیت عرض برای دسکتاپ
              child: Column(
                children: [
                  // تبلیغ
                  if (!_isAdLoading && _activeAd != null)
                    Container(
                      width: double.infinity,
                      height: 120,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                      ),
                      child: InkWell(
                        onTap: _launchAdLink,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _activeAd!['image'] != null
                              ? Image.network(_activeAd!['image'], fit: BoxFit.cover)
                              : Center(child: Text(_activeAd!['title'] ?? 'تبلیغات', style: const TextStyle(fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),

                  // جستجو
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'جستجو (محله، شهر...)',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (_) => _performSearch(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // دکمه‌های نوع معامله
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildTypeButton('خرید', 'SA'),
                        const SizedBox(width: 10),
                        _buildTypeButton('رهن و اجاره', 'RE'), 
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // لیست نتایج
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final listing = _searchResults[index];
                              return ListTile(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing))),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 60, height: 60,
                                    child: listing.imageUrl != null 
                                      ? Image.network(listing.imageUrl!, fit: BoxFit.cover)
                                      : Container(color: Colors.grey, child: const Icon(Icons.home)),
                                  ),
                                ),
                                title: Text(listing.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${listing.city} | ${listing.price ?? "توافقی"}'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String title, String value) {
    bool isSelected = _selectedTransaction == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTransaction = value);
          _performSearch();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
