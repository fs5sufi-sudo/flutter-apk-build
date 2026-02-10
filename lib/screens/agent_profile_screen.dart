import 'package:flutter/material.dart';
import '../models/agent.dart';
import '../models/listing.dart';
import '../services/api_service.dart';
import 'listing_detail_screen.dart';

class AgentProfileScreen extends StatefulWidget {
  final int agentId;
  const AgentProfileScreen({super.key, required this.agentId});

  @override
  State<AgentProfileScreen> createState() => _AgentProfileScreenState();
}

class _AgentProfileScreenState extends State<AgentProfileScreen> {
  late Future<Agent> _agentFuture;
  late Future<List<Listing>> _listingsFuture;

  @override
  void initState() {
    super.initState();
    _agentFuture = ApiService().fetchAgentProfile(widget.agentId);
    _listingsFuture = ApiService().fetchAgentListings(widget.agentId);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1200 ? 5 : screenWidth > 900 ? 4 : screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('پروفایل مشاور', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF4F6F8),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder<Agent>(
                    future: _agentFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator());
                      if (snapshot.hasError) return const Padding(padding: EdgeInsets.all(20), child: Text('خطا در دریافت اطلاعات'));
                      
                      final agent = snapshot.data!;
                      return Center(
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 600),
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: agent.avatarUrl != null ? NetworkImage(agent.avatarUrl!) : null,
                                child: agent.avatarUrl == null ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                agent.username,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E2746)),
                              ),
                              if (agent.bio != null && agent.bio!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  agent.bio!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                                ),
                              ],
                              const SizedBox(height: 24),
                              
                              // فقط دکمه تماس باقی ماند (چت حذف شد)
                              SizedBox(
                                width: 200,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تماس با: ${agent.phoneNumber ?? "نامشخص"}')));
                                  },
                                  icon: const Icon(Icons.phone, size: 20),
                                  label: const Text('تماس تلفنی', style: TextStyle(fontSize: 16)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green, 
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8), child: Divider()),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: const [
                        Icon(Icons.grid_on_rounded, size: 20, color: Color(0xFF1E2746)),
                        SizedBox(width: 8),
                        Text('آگهی‌های این مشاور', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E2746))),
                      ],
                    ),
                  ),

                  FutureBuilder<List<Listing>>(
                    future: _listingsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (snapshot.hasError) return const Center(child: Text('خطا در دریافت آگهی‌ها'));
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return const Padding(padding: EdgeInsets.all(40), child: Text('هنوز آگهی ثبت نکرده است.'));

                      final listings = snapshot.data!;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: listings.length,
                        itemBuilder: (context, index) {
                          final listing = listings[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing))),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: listing.imageUrl != null
                                          ? Image.network(listing.imageUrl!, fit: BoxFit.cover, width: double.infinity)
                                          : Container(color: Colors.grey.shade200, child: const Icon(Icons.image)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text(listing.city, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                          Text(listing.price ?? 'توافقی', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE76F51))),
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
                ],
              ),
            ),   
          ),
        ),
      ),
    );
  }
}
