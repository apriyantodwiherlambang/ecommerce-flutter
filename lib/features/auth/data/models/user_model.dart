import '../../domain/entities/user.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String? profilePictureUrl;
  final String? jwt;
  final String? refreshToken;
  final String? role;
  final String? address;
  final String? phoneNumber;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.profilePictureUrl,
    this.jwt,
    this.refreshToken,
    this.role,
    this.address,
    this.phoneNumber,
  });

  /// Factory constructor untuk dari JSON.
  ///
  /// Kalau ada nested `user` (seperti di response login), parsing dari `json['user']`.
  /// Kalau tidak ada, parsing langsung dari `json`.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      print("Login/Update Response: $json");

      // Cek apakah ada nested 'user' di JSON
      final userJson = json.containsKey('user') ? json['user'] : json;

      return UserModel(
        id: userJson['id'],
        username: userJson['username'],
        email: userJson['email'],
        profilePictureUrl:
            userJson['profileImage'] ?? userJson['profile_picture_url'],
        jwt: json[
            'accessToken'], // biasanya ada di root JSON login, bisa null kalau update
        refreshToken: userJson['refreshToken'] ?? json['refreshToken'],
        role: userJson['role'],
        address: userJson['address'],
        phoneNumber: userJson['phoneNumber'],
      );
    } catch (e) {
      print("Error parsing UserModel: $e");
      rethrow;
    }
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      email: email,
      profilePictureUrl: profilePictureUrl,
      jwt: jwt,
      refreshToken: refreshToken,
      role: role,
      address: address,
      phoneNumber: phoneNumber,
    );
  }
}
