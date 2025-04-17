import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<UserEntity> login(String email, String password) async {
    final userModel = await remoteDatasource.login(email, password);
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> register(
      String username, String email, String password) async {
    final userModel =
        await remoteDatasource.register(username, email, password);
    return userModel.toEntity();
  }
}
