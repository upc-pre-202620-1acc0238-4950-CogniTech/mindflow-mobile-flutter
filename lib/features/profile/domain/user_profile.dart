class UserProfile {
  final int id;
  final String email;
  final String? name;
  final String? occupation;

  const UserProfile({required this.id, required this.email, this.name, this.occupation});

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as int,
        email: json['email'] as String,
        name: json['name'] as String?,
        occupation: json['occupation'] as String?,
      );

  String get displayName => (name == null || name!.trim().isEmpty) ? email.split('@').first : name!;
}
