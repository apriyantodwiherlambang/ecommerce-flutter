import '../../domain/entities/user.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String? jwt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.jwt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return UserModel(
      id: user['id'], // id as int
      username: user['username'],
      email: user['email'],
      jwt: json['accessToken'],
    );
  }

  // Mengonversi UserModel ke UserEntity tanpa jwt
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      email: email,
      profilePictureUrl: null, // Menambahkan properti jika perlu
      jwt: jwt ?? '', // Menyertakan nilai default untuk jwt
    );
  }
}
