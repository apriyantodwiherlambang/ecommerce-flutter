import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

// Import auth module
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/fetch_user_profile_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'domain/usecases/update_user_usecase.dart';
import 'domain/usecases/upload_profile_image_usecase.dart' as upload_image;
import './presentation/cubit/auth_cubit.dart';

final sl = GetIt.instance;

void initAuth() {
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDatasource: sl(),
      ));

  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl()));
  sl.registerLazySingleton<UpdateUserUseCase>(() => UpdateUserUseCase(sl()));
  sl.registerLazySingleton<FetchUserProfileUseCase>(
      () => FetchUserProfileUseCase(sl()));
  sl.registerLazySingleton<upload_image.UploadProfileImageUseCase>(
      () => upload_image.UploadProfileImageUseCase(sl()));

  sl.registerFactory<AuthCubit>(() => AuthCubit(
        loginUseCase: sl(),
        registerUseCase: sl(),
        updateUserUseCase: sl(),
        fetchUserProfileUseCase: sl(),
        uploadProfileImageUseCase: sl(),
        cartCubit: sl(),
        dio: sl(),
      ));
}
