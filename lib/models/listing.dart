class Listing {
  final int id;
  final String title;
  final String description;
  final String city;
  final String propertyType;
  final String transactionType;
  final String? price;
  final String? rentPrice;
  final int area;
  final String? imageUrl;
  final List<GalleryImage> gallery;
  final DateTime createdAt;
  final bool isFavorited;
  final int agentId;
  final String? agentName; // جدید
  final String? agentAvatar; // جدید

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.propertyType,
    required this.transactionType,
    this.price,
    this.rentPrice,
    required this.area,
    this.imageUrl,
    required this.gallery,
    required this.createdAt,
    required this.isFavorited,
    required this.agentId,
    this.agentName,
    this.agentAvatar,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    var galleryList = <GalleryImage>[];
    if (json['gallery'] != null) {
      json['gallery'].forEach((v) {
        galleryList.add(GalleryImage.fromJson(v));
      });
    }

    // دریافت اطلاعات مشاور
    String? aName;
    String? aAvatar;
    if (json['agent_info'] != null) {
      aName = json['agent_info']['username'];
      aAvatar = json['agent_info']['avatar'];
    }

    return Listing(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      city: json['city'],
      propertyType: json['property_type'],
      transactionType: json['transaction_type'],
      price: json['price'],
      rentPrice: json['rent_price'],
      area: json['area'],
      imageUrl: json['image'],
      gallery: galleryList,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isFavorited: json['is_favorited'] ?? false,
      agentId: json['agent'] ?? 0,
      agentName: aName,
      agentAvatar: aAvatar,
    );
  }
}

class GalleryImage {
  final int id;
  final String imageUrl;
  GalleryImage({required this.id, required this.imageUrl});
  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(id: json['id'], imageUrl: json['image']);
  }
}
