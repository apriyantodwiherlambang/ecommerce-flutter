import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../domain/entities/user.dart';
import 'auth_state.dart';
import 'package:frontend_ecommerce/core/secure_storage.dart'; // Import secure_storage.dart

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final UpdateUserUseCase updateUserUseCase;

  UserEntity? currentUser;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.updateUserUseCase,
  }) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase.execute(email, password);
      currentUser = user;
      await saveJwt(user.jwt); // Menyimpan JWT setelah login
      emit(AuthSuccess('Login berhasil. Selamat datang, ${user.username}'));
    } catch (e) {
      emit(AuthError('Login gagal: ${e.toString()}'));
    }
  }

  Future<void> register(String username, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase.execute(username, email, password);
      currentUser = user;
      await saveJwt(user.jwt); // Menyimpan JWT setelah registrasi
      emit(AuthSuccess('Register berhasil. Selamat datang, ${user.username}'));
    } catch (e) {
      emit(AuthError('Register gagal: ${e.toString()}'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      currentUser = null;
      await deleteJwt(); // Hapus JWT saat logout
      emit(AuthSuccess(
          'Logout berhasil. Terima kasih, semoga harimu menyenangkan!'));
    } catch (e) {
      emit(AuthError('Logout gagal: ${e.toString()}'));
    }
  }

  Future<void> updateUser({
    required String username,
    required String email,
    String? password,
  }) async {
    emit(AuthLoading());
    try {
      final jwt = await getJwt();

      if (jwt?.isNotEmpty ?? false) {
        final updatedUser = await updateUserUseCase.execute(
          currentUser!.id,
          username,
          email,
          password,
          jwt!, // ⬅️ kirimkan jwt
        );
        currentUser = updatedUser;
        emit(AuthSuccess('Update berhasil'));
      } else {
        emit(AuthError('JWT tidak ditemukan!'));
      }
    } catch (e) {
      emit(AuthError('Update gagal: ${e.toString()}'));
    }
  }
}
