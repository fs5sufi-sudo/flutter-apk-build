class SubscriptionPackage {
  final int id;
  final String name;
  final String price;
  final int listingsCount;

  SubscriptionPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.listingsCount,
  });

  factory SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackage(
      id: json['id'],
      name: json['name'],
      // قیمت را به رشته تبدیل می‌کنیم تا اگر عدد بود خطا ندهد
      price: json['price'].toString(),
      listingsCount: json['listings_count'],
    );
  }
}
