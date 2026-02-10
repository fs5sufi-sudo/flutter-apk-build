import '../services/auth_service.dart';

class User {
  final int? id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? bio;
  final String? avatar;
  
  // نقش‌ها
  final bool isAgent;
  final bool isStaff;
  final bool isApproved;

  User({
    this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.bio,
    this.avatar,
    this.isAgent = false,
    this.isStaff = false,
    this.isApproved = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      bio: json['bio'],
      avatar: _fixAvatarUrl(json['avatar'] ?? json['avatar_url']),
      isAgent: json['is_agent'] ?? false,
      isStaff: json['is_staff'] ?? false,
      isApproved: json['is_approved'] ?? false,
    );
  }

  // تشخیص نقش طبق سند
  String get role {
    if (isStaff) return 'admin';
    if (isAgent) return 'agent';
    return 'user';
  }

  static String? _fixAvatarUrl(String? url) {
    if (url == null) return null;
    if (url.startsWith('http')) return url;
    final base = AuthService.baseUrl.replaceAll('/api', '');
    return '$base$url';
  }
}
