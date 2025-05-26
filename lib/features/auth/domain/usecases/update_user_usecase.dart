import 'dart:io';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateUserUseCase {
  final AuthRepository repository;

  UpdateUserUseCase(this.repository);

  Future<UserEntity> execute(
    int id,
    String username,
    String email,
    String? password,
    String? address,
    String? phoneNumber,
    File? profileImageFile,
    String jwt,
  ) {
    return repository.updateUser(
      id,
      username,
      email,
      password,
      address,
      phoneNumber,
      profileImageFile,
      jwt,
    );
  }
}

class UploadProfileImageUseCase {
  final AuthRepository repository;

  UploadProfileImageUseCase(this.repository);

  Future<UserEntity> execute(File imageFile, String jwt) {
    return repository.uploadProfileImage(imageFile, jwt);
  }
}
