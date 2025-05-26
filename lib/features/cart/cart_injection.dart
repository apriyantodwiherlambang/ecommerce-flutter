import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_ecommerce/features/auth/data/api_service.dart';
import 'package:frontend_ecommerce/features/cart/cart_cubit.dart';
import 'package:frontend_ecommerce/features/cart/cart_remote_datasource.dart';

final sl = GetIt.instance;

void setupCartInjection() {
  print('setupCartInjection started');

  // Register FlutterSecureStorage jika belum
  if (!sl.isRegistered<FlutterSecureStorage>()) {
    sl.registerLazySingleton<FlutterSecureStorage>(
        () => const FlutterSecureStorage());
  }

  // Register Dio jika belum
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(
          baseUrl: 'https://44ba-66-96-225-191.ngrok-free.app',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        )));
  }

  // Register ApiService (cukup dengan baseUrl saja)
  if (!sl.isRegistered<ApiService>()) {
    sl.registerLazySingleton<ApiService>(
      () => ApiService('https://44ba-66-96-225-191.ngrok-free.app'),
    );
  }

  // Register CartRemoteDatasource dengan 2 parameter (Dio dan ApiService)
  if (!sl.isRegistered<CartRemoteDatasource>()) {
    sl.registerLazySingleton<CartRemoteDatasource>(
      () => CartRemoteDatasource(sl<Dio>(), sl<ApiService>()),
    );
  }

  // Register CartCubit
  if (!sl.isRegistered<CartCubit>()) {
    sl.registerFactory<CartCubit>(
      () => CartCubit(sl<CartRemoteDatasource>()),
    );
  }

  print('setupCartInjection completed');
}
