import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateUserUseCase {
  final AuthRepository repository;

  UpdateUserUseCase(this.repository);

  Future<UserEntity> execute(
      int id, String username, String email, String? password, String jwt) {
    return repository.updateUser(id, username, email, password, jwt);
  }
}
