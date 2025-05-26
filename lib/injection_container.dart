// injection_container.dart

import 'package:frontend_ecommerce/features/auth/data/api_service.dart';
import 'package:frontend_ecommerce/features/cart/cart_cubit.dart';
import 'package:frontend_ecommerce/features/categories/category_injection.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/auth/auth_injection.dart';
import 'features/products/product_injection.dart';

// Import cart injection
import 'features/cart/cart_injection.dart';

final sl = GetIt.instance;

Future<void> initCoreDependencies() async {
  if (!sl.isRegistered<Dio>()) {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    print('Base URL di Core: $baseUrl');

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print("Request: ${options.method} ${options.uri}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("Response: ${response.statusCode} ${response.data}");
          return handler.next(response);
        },
        onError: (DioError e, handler) {
          print("Error: ${e.message}");
          return handler.next(e);
        },
      ),
    );

    sl.registerLazySingleton<Dio>(() => dio);
    sl.registerLazySingleton<ApiService>(() => ApiService(baseUrl));
  }
}

Future<void> initDependencies() async {
  print('Init dependencies dimulai');

  await initCoreDependencies(); // Pastikan Dio dan ApiService sudah terdaftar

  initAuth();
  print('Auth injection done');

  initProductInjection();
  print('Product injection done');

  initCategoryInjection();
  print('Category injection done');

  // Panggil setup cart injection di sini
  setupCartInjection();
  print('Cart injection done');

  print('CartCubit registered: ${sl.isRegistered<CartCubit>()}'); // <- tambahan
  // Inisialisasi modul lain jika ada
}
