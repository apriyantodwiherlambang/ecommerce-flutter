import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String username, String email, String password);
  Future<UserEntity> updateUser(
      int id, String username, String email, String? password, String jwt);
}
