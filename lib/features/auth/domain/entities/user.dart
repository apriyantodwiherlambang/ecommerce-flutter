class UserEntity {
  final int id;
  final String username;
  final String email;
  final String? profilePictureUrl;
  final String jwt;

  UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.profilePictureUrl,
    required this.jwt,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profilePictureUrl: json['profilePictureUrl'],
      jwt: json['jwt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'jwt': jwt,
    };
  }
}
