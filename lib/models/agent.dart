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
    return Agent(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      bio: json['bio'],
      avatarUrl: json['avatar'],
    );
  }
}
