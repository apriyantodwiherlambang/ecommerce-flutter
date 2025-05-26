import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class FetchUserProfileUseCase {
  final AuthRepository repository;

  FetchUserProfileUseCase(this.repository);

  Future<UserEntity> execute(String jwt) {
    return repository.fetchUserProfile(jwt);
  }
}
