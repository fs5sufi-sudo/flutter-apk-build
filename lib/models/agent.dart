import '../services/auth_service.dart'; // برای دسترسی به baseUrl

class Agent {
  final int id;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? bio;
  final String? avatarUrl;

  Agent({
    required this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.bio,
    this.avatarUrl,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    // ⚠️ اصلاح مهم: ساخت آدرس کامل برای عکس
    String? avatar = json['avatar'];
    if (avatar != null && !avatar.startsWith('http')) {
       // حذف /api از آخر baseUrl برای دسترسی به مدیا
       final base = AuthService.baseUrl.replaceAll('/api', '');
       avatar = '$base$avatar';
    }

    return Agent(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      bio: json['bio'],
      avatarUrl: avatar,
    );
  }
}
