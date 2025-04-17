import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';
import '../pages/home_page.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthCubit({required this.loginUseCase, required this.registerUseCase})
      : super(AuthInitial());

  Future<void> login(
      String email, String password, BuildContext context) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase.execute(email, password);
      emit(AuthSuccess('Login berhasil. Selamat datang, ${user.username}'));

      // Navigasi setelah login berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const HomePage()), // Ganti dengan halaman yang sesuai
      );
    } catch (e) {
      emit(AuthError('Login gagal: ${e.toString()}'));
    }
  }

  Future<void> register(String username, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase.execute(username, email, password);
      emit(AuthSuccess('Register berhasil. Selamat datang, ${user.username}'));
    } catch (e) {
      emit(AuthError('Register gagal: ${e.toString()}'));
    }
  }
}
