import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_ecommerce/features/cart/cart_cubit.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../domain/usecases/fetch_user_profile_usecase.dart';
import '../../domain/usecases/upload_profile_image_usecase.dart'
    as upload_image;
import '../../domain/entities/user.dart';
import 'auth_state.dart';
import 'package:frontend_ecommerce/core/secure_storage.dart';
import 'package:dio/dio.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final FetchUserProfileUseCase fetchUserProfileUseCase;
  final upload_image.UploadProfileImageUseCase uploadProfileImageUseCase;
  final CartCubit cartCubit;
  final Dio dio;

  UserEntity? currentUser;
  File? newProfileImage;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.updateUserUseCase,
    required this.fetchUserProfileUseCase,
    required this.uploadProfileImageUseCase,
    required this.cartCubit,
    required this.dio,
  }) : super(AuthInitial());

  bool get isAdmin => currentUser?.role == 'admin';

  void setNewProfileImage(File image) {
    newProfileImage = image;
    emit(AuthProfileImageUpdated());
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase.execute(email, password);
      currentUser = user;

      await saveJwt(user.jwt);
      await saveRefreshToken(user.refreshToken);
      dio.options.headers['Authorization'] = 'Bearer ${user.jwt}';

      emit(AuthSuccess('Login berhasil. Selamat datang, ${user.username}'));
      await cartCubit.fetchCart();
    } catch (e) {
      emit(AuthError('Login gagal: ${_parseError(e)}'));
    }
  }

  Future<void> register(String username, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase.execute(username, email, password);
      currentUser = user;

      await saveJwt(user.jwt);
      await saveRefreshToken(user.refreshToken);
      dio.options.headers['Authorization'] = 'Bearer ${user.jwt}';

      emit(AuthSuccess('Register berhasil. Selamat datang, ${user.username}'));
    } catch (e) {
      emit(AuthError('Register gagal: ${_parseError(e)}'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      currentUser = null;
      newProfileImage = null;

      await deleteJwt();
      await deleteRefreshToken();

      dio.options.headers.remove('Authorization');
      cartCubit.clearCartState();
      emit(AuthSuccess('Logout berhasil.'));
    } catch (e) {
      emit(AuthError('Logout gagal: ${_parseError(e)}'));
    }
  }

  Future<void> updateUser({
    required String username,
    required String email,
    String? password,
    String? address,
    String? phoneNumber,
    File? profileImageFile,
  }) async {
    emit(AuthLoading());
    try {
      if (currentUser == null) {
        emit(AuthError('User belum login.'));
        return;
      }

      final jwt = await getJwt();
      if (jwt == null || jwt.isEmpty) {
        emit(AuthError('Token tidak ditemukan!'));
        return;
      }

      final updatedUser = await updateUserUseCase.execute(
        currentUser!.id,
        username,
        email,
        password,
        address,
        phoneNumber,
        profileImageFile,
        jwt,
      );

      currentUser = updatedUser;
      newProfileImage = null;

      await saveJwt(updatedUser.jwt);
      await saveRefreshToken(updatedUser.refreshToken);
      dio.options.headers['Authorization'] = 'Bearer ${updatedUser.jwt}';

      await fetchCurrentUser(); // emit di dalamnya
    } catch (e) {
      if (_isTokenExpired(e)) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          await updateUser(
            username: username,
            email: email,
            password: password,
            address: address,
            phoneNumber: phoneNumber,
            profileImageFile: profileImageFile,
          );
          return;
        }
      }
      emit(AuthError('Update profil gagal: ${_parseError(e)}'));
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final jwt = await getJwt();

      if (jwt == null || jwt.isEmpty) {
        currentUser = null;
        emit(AuthInitial());
        return;
      }

      dio.options.headers['Authorization'] = 'Bearer $jwt';

      final user = await fetchUserProfileUseCase.execute(jwt);

      if (user == null) {
        // Jika user null, emit error atau state lain sesuai kebutuhan
        emit(AuthError('Data user tidak ditemukan'));
        return;
      }

      currentUser = user;
      newProfileImage = null;

      emit(AuthProfileLoaded(user));
    } catch (e) {
      if (_isTokenExpired(e)) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          await fetchCurrentUser(); // retry
          return;
        }
      }
      emit(AuthError('Gagal memuat data user: ${_parseError(e)}'));
    }
  }

  Future<void> uploadProfileImage(File imageFile) async {
    emit(AuthLoading());
    try {
      if (currentUser == null) {
        emit(AuthError('User belum login.'));
        return;
      }

      final jwt = await getJwt();
      if (jwt == null || jwt.isEmpty) {
        emit(AuthError('Token tidak ditemukan!'));
        return;
      }

      final updatedUser =
          await uploadProfileImageUseCase.execute(imageFile, jwt);
      currentUser = updatedUser;
      newProfileImage = null;

      await saveJwt(updatedUser.jwt);
      await saveRefreshToken(updatedUser.refreshToken);
      dio.options.headers['Authorization'] = 'Bearer ${updatedUser.jwt}';

      await fetchCurrentUser();
    } catch (e) {
      if (_isTokenExpired(e)) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          await uploadProfileImage(imageFile);
          return;
        }
      }
      emit(AuthError('Gagal upload foto profil: ${_parseError(e)}'));
    }
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      final newAccessToken = response.data['accessToken'];
      if (newAccessToken != null) {
        await saveJwt(newAccessToken);
        dio.options.headers['Authorization'] = 'Bearer $newAccessToken';
        return true;
      }
    } catch (_) {}
    return false;
  }

  // String _parseError(dynamic error) {
  //   if (error is DioError) {
  //     return error.response?.data['message'] ??
  //         error.response?.data['error'] ??
  //         error.message;
  //   }
  //   return error.toString();
  // }

  String _parseError(dynamic error) {
    if (error is DioException) {
      // Ganti DioError menjadi DioException (lebih modern)
      final responseData = error.response?.data;

      // Periksa jika responseData adalah Map (objek JSON)
      if (responseData is Map<String, dynamic>) {
        // Prioritaskan 'message', lalu 'error', atau pesan default
        return responseData['message'] ??
            responseData['error'] ??
            error.message ?? // Fallback ke message dari DioException
            'Terjadi kesalahan yang tidak diketahui dari server.';
      }
      // Periksa jika responseData adalah String (pesan sederhana)
      else if (responseData is String) {
        return responseData; // Langsung kembalikan string tersebut sebagai pesan error
      }
      // Periksa jika responseData adalah List (mungkin list error)
      else if (responseData is List) {
        if (responseData.isNotEmpty) {
          // Ambil elemen pertama atau gabungkan semuanya
          return responseData.first.toString();
        }
      }

      // Jika tidak ada format yang dikenali, fallback ke message dari DioException
      return error.message ??
          'Terjadi kesalahan tidak dikenal saat memproses respon.';
    }
    // Jika error bukan DioException, kembalikan representasi string-nya
    return error.toString();
  }

  bool _isTokenExpired(dynamic error) {
    if (error is DioError) {
      return error.response?.statusCode == 401;
    }
    return false;
  }
}
