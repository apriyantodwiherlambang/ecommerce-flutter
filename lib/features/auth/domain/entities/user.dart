class UserEntity {
  final int id;
  final String username;
  final String email;
  final String? profilePictureUrl;
  final String? jwt;
  final String? refreshToken;
  final String? role;
  final String? address; // tambahkan ini
  final String? phoneNumber; // tambahkan ini

  UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.profilePictureUrl,
    this.jwt,
    this.refreshToken,
    this.role,
    this.address, // baru
    this.phoneNumber, // baru
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profilePictureUrl: json['profilePictureUrl'],
      jwt: json['accessToken'],
      refreshToken: json['refreshToken'],
      role: json['role'],
      address: json['address'], // baru
      phoneNumber: json['phoneNumber'], // baru
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'jwt': jwt,
      'refreshToken': refreshToken,
      'role': role,
      'address': address, // baru
      'phoneNumber': phoneNumber, // baru
    };
  }
}
