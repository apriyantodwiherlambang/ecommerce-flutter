import 'package:dio/dio.dart';
import 'package:frontend_ecommerce/features/auth/data/api_service.dart';
import 'package:frontend_ecommerce/features/products/domain/usecases/fetch_products_usecase.dart';
import 'package:get_it/get_it.dart';

// Import interface repository dari domain
import 'domain/repositories/products_repository.dart';

// Import data source dan implementasi repository dengan alias supaya tidak bentrok
import 'data/datasources/products_remote_datasource.dart' as remote_ds;
import 'data/repositories/products_repository_impl.dart' as repo_impl;

import 'domain/usecases/upload_product.dart';
import 'presentation/cubit/product_upload_cubit.dart' as upload;
import 'presentation/cubit/product_cubit.dart';

final sl = GetIt.instance;

void initProductInjection() {
  print('initProductInjection started');
  print('Registered ProductCubit? ${GetIt.I.isRegistered<ProductCubit>()}');

  // existing registration code
  print('ProductCubit registered: ${sl.isRegistered<ProductCubit>()}');
  print('initProductInjection completed');

  // Pastikan Dio dan ApiService sudah terdaftar sebelum initProductInjection dipanggil
  if (!sl.isRegistered<Dio>() || !sl.isRegistered<ApiService>()) {
    throw Exception(
      'Dio atau ApiService belum didaftarkan di GetIt sebelum initProductInjection dipanggil',
    );
  }

  // Data source
  sl.registerLazySingleton<remote_ds.ProductsRemoteDataSource>(
    () => remote_ds.ProductsRemoteDataSourceImpl(
      sl<Dio>(),
      sl<ApiService>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<ProductsRepository>(
    () => repo_impl.ProductsRepositoryImpl(
      sl<remote_ds.ProductsRemoteDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<UploadProduct>(
    () => UploadProduct(sl<ProductsRepository>()),
  );
  // sl.registerLazySingleton<FetchProductsUseCase>(
  //   () => FetchProductsUseCase(sl<ProductsRepository>()),
  // );

  if (!sl.isRegistered<FetchProductsUseCase>()) {
    sl.registerLazySingleton<FetchProductsUseCase>(
      () => FetchProductsUseCase(sl<ProductsRepository>()),
    );
  }

  // Cubits
  sl.registerFactory<upload.ProductUploadCubit>(
    () => upload.ProductUploadCubit(sl<UploadProduct>()),
  );

// Jika ingin factory
  sl.registerFactory<ProductCubit>(
    () => ProductCubit(sl<FetchProductsUseCase>()),
  );

  // if (!sl.isRegistered<ProductCubit>()) {
  //   sl.registerFactory<ProductCubit>(
  //     () => ProductCubit(sl<FetchProductsUseCase>()),
  //   );
  // }

  print('ProductCubit registered: ${sl.isRegistered<ProductCubit>()}');
}
