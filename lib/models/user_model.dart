class UserModel {
  final String id;
  final String? email;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final String? phoneNumber;
  final String presence; // ONLINE, OFFLINE
  final DateTime? lastSeen;

  UserModel({
    required this.id,
    this.email,
    this.username,
    this.avatarUrl,
    this.bio,
    this.phoneNumber,
    this.presence = 'OFFLINE',
    this.lastSeen,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      phoneNumber: json['phoneNumber'],
      presence: json['presence'] ?? 'OFFLINE',
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'presence': presence,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }
}
