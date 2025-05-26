import 'dart:io';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl({required this.remoteDatasource});

  @override
  Future<UserEntity> login(String email, String password) async {
    final response = await remoteDatasource.login(email, password);
    final userModel = UserModel.fromJson(response);
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> register(
      String username, String email, String password) async {
    final userModel =
        await remoteDatasource.register(username, email, password);
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> updateUser(
    int id,
    String username,
    String email,
    String? password,
    String? address,
    String? phoneNumber,
    File? profileImageFile,
    String jwt,
  ) async {
    final userModel = await remoteDatasource.updateUser(
      id,
      username,
      email,
      password,
      address,
      phoneNumber,
      profileImageFile,
      jwt,
    );

    return userModel.toEntity();
  }

  @override
  Future<UserEntity> fetchUserProfile(String jwt) async {
    final userModel = await remoteDatasource.fetchUserProfile(jwt);
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> uploadProfileImage(File imageFile, String jwt) async {
    final userModel = await remoteDatasource.uploadProfileImage(imageFile, jwt);
    return userModel.toEntity();
  }
}
