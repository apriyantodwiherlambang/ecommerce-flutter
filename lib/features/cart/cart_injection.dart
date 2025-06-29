import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
// Hapus import FlutterSecureStorage karena sudah tidak diperlukan di sini
// Hapus import ApiService jika Anda memutuskan tidak lagi menggunakannya di CartRemoteDatasource

import 'package:frontend_ecommerce/features/cart/cart_cubit.dart';
import 'package:frontend_ecommerce/features/cart/cart_remote_datasource.dart';
import 'package:frontend_ecommerce/features/auth/data/api_service.dart'; // Tetap import jika ApiService masih diinjeksi ke CartRemoteDatasource

final sl = GetIt.instance;

void setupCartInjection() {
  print('setupCartInjection started');

  // Hapus semua pendaftaran Dio, FlutterSecureStorage, dan ApiService di sini.
  // Mereka seharusnya hanya didaftarkan dan dikonfigurasi di `initCoreDependencies`
  // di `injection_container.dart`.

  // Register CartRemoteDatasource.
  // Pastikan `sl<Dio>()` mengambil instance Dio yang sudah diintersep JWT dari GetIt.
  // Jika Anda memutuskan untuk menghapus ApiService dari CartRemoteDatasource,
  // maka hapus juga `sl<ApiService>()` di baris ini.
  if (!sl.isRegistered<CartRemoteDatasource>()) {
    sl.registerLazySingleton<CartRemoteDatasource>(
      () => CartRemoteDatasource(sl<Dio>(), sl<ApiService>()),
    );
  }

  // Register CartCubit.
  if (!sl.isRegistered<CartCubit>()) {
    sl.registerFactory<CartCubit>(
      () => CartCubit(sl<CartRemoteDatasource>()),
    );
  }

  print('setupCartInjection completed');
}
