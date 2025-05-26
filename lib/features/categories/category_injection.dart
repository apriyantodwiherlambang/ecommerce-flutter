import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'data/datasources/categories_remote_datasource.dart';
import 'data/datasources/categories_remote_datasource_impl.dart';
import 'data/repositories/categories_repository_impl.dart';
import 'domain/repositories/categories_repository.dart';
import 'domain/usecases/fetch_categories.dart';
import 'presentation/cubit/category_cubit.dart';

final sl = GetIt.instance;

void initCategoryInjection() {
  sl.registerLazySingleton<CategoriesRemoteDatasource>(
    () => CategoriesRemoteDatasourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(sl<CategoriesRemoteDatasource>()),
  );

  sl.registerLazySingleton(() => FetchCategories(sl<CategoriesRepository>()));

  // Tambahkan ini
  sl.registerFactory(() => CategoryCubit(sl<FetchCategories>()));
}
