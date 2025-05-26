// domain/usecases/upload_profile_image_usecase.dart
import 'dart:io';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UploadProfileImageUseCase {
  final AuthRepository repository;

  UploadProfileImageUseCase(this.repository);

  Future<UserEntity> execute(File imageFile, String jwt) {
    return repository.uploadProfileImage(imageFile, jwt);
  }
}
