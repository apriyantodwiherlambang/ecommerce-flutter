// injection_container.dart

import 'package:frontend_ecommerce/core/secure_storage.dart';
import 'package:frontend_ecommerce/features/auth/data/api_service.dart';
import 'package:frontend_ecommerce/features/cart/cart_cubit.dart';
import 'package:frontend_ecommerce/features/categories/category_injection.dart';
import 'package:frontend_ecommerce/features/payment/payment_cubit.dart';

// --- Import modules yang dibutuhkan untuk Payment dan Order ---// <-- Pastikan file ini ada
import 'package:frontend_ecommerce/features/order/order_remote_datasource.dart';
import 'package:frontend_ecommerce/features/order/order_cubit.dart';
import 'package:frontend_ecommerce/features/payment/payment_remote_datasource.dart';
import 'package:frontend_ecommerce/features/payment/payment_websocket_service.dart';
// -------------------------------------------------------------

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/auth/auth_injection.dart';
import 'features/products/product_injection.dart';

// Import cart injection
import 'features/cart/cart_injection.dart';

final sl = GetIt.instance;

Future<void> initCoreDependencies() async {
  // Hanya daftarkan Dio dan ApiService jika belum terdaftar
  // Ini menghindari error 'already registered' jika initDependencies dipanggil berkali-kali
  if (!sl.isRegistered<Dio>()) {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    print('Base URL di Core: $baseUrl');

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print("Request: ${options.method} ${options.uri}");
          final jwt = await getJwt();
          if (jwt != null && jwt.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $jwt';
            print('Adding Authorization header: Bearer $jwt');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("Response: ${response.statusCode} ${response.data}");
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Ganti DioError menjadi DioException
          print("Error: ${e.message}");
          if (e.response?.statusCode == 401) {
            print('Unauthorized error, potentially token expired.');
            // Anda bisa menambahkan logika logout atau refresh token di sini
            // atau biarkan Bloc/Cubit yang menangkap error ini dan melakukan logout.
          }
          return handler.next(e);
        },
      ),
    );

    sl.registerLazySingleton<Dio>(() => dio);
    // Jika ApiService Anda memerlukan Dio, daftarkan setelah Dio
    sl.registerLazySingleton<ApiService>(() => ApiService(
        baseUrl)); // ApiService mungkin tidak butuh Dio jika hanya untuk baseUrl
  }
}

void setupPaymentInjection() {
  if (!sl.isRegistered<PaymentRemoteDatasource>()) {
    sl.registerLazySingleton<PaymentRemoteDatasource>(
      () => PaymentRemoteDatasource(sl()),
    );
  }

  if (!sl.isRegistered<PaymentWebSocketService>()) {
    sl.registerLazySingleton<PaymentWebSocketService>(
      () => PaymentWebSocketService(),
    );
  }

  if (!sl.isRegistered<PaymentCubit>()) {
    sl.registerFactory<PaymentCubit>(
      () => PaymentCubit(
        sl<PaymentRemoteDatasource>(),
      ),
    );
  }
}

// Fungsi untuk injeksi Order
void setupOrderInjection() {
  if (!sl.isRegistered<OrderRemoteDatasource>()) {
    sl.registerLazySingleton<OrderRemoteDatasource>(
      () => OrderRemoteDatasource(sl()), // Membutuhkan Dio
    );
  }
  if (!sl.isRegistered<OrderCubit>()) {
    sl.registerFactory<OrderCubit>(
      () => OrderCubit(sl()), // Membutuhkan OrderRemoteDatasource
    );
  }
}

Future<void> initDependencies() async {
  print('Init dependencies dimulai');

  // Selalu panggil initCoreDependencies pertama
  await initCoreDependencies();
  print('Core dependencies done');

  initAuth();
  print('Auth injection done');

  initProductInjection();
  print('Product injection done');

  initCategoryInjection();
  print('Category injection done');

  setupCartInjection();
  print('Cart injection done');

  // --- Tambahkan inisialisasi Payment dan Order ---
  setupPaymentInjection();
  print('Payment injection done');

  setupOrderInjection();
  print('Order injection done');
  // ---------------------------------------------

  // Log pendaftaran untuk debugging
  print('CartCubit registered: ${sl.isRegistered<CartCubit>()}');
  print('PaymentCubit registered: ${sl.isRegistered<PaymentCubit>()}');
  print('OrderCubit registered: ${sl.isRegistered<OrderCubit>()}');
  print('All dependencies initialized.');
}
