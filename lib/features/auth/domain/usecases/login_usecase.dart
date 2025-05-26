import '../repositories/auth_repository.dart';
import '../entities/user.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> execute(String email, String password) async {
    final user = await repository.login(email, password);

    // Tidak perlu akses seperti Map lagi
    return user;
  }
}
