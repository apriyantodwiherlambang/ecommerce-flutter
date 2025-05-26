import 'dart:io';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String username, String email, String password);

  Future<UserEntity> updateUser(
    int id,
    String username,
    String email,
    String? password,
    String? address,
    String? phoneNumber,
    File? profileImageFile,
    String jwt,
  );

  Future<UserEntity> fetchUserProfile(String jwt);
  Future<UserEntity> uploadProfileImage(File imageFile, String jwt);
}
