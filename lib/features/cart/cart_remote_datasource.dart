import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend_ecommerce/features/auth/data/api_service.dart';
import './cart_model.dart';

class CartRemoteDatasource {
  final Dio dio;
  final ApiService apiService;

  CartRemoteDatasource(this.dio, this.apiService) {
    // Pastikan baseUrl sudah diset di Dio dari injection, jangan di-set ulang disini

    // Pasang interceptor untuk set header Authorization otomatis sebelum request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await apiService.getJwt();
          if (token == null || token.isEmpty) {
            if (kDebugMode) print('Token JWT kosong saat request');
          } else {
            options.headers['Authorization'] = 'Bearer $token';
            if (kDebugMode)
              print('Interceptor set Authorization: Bearer $token');
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<List<CartItemModel>> getCart() async {
    try {
      final response = await dio.get('/cart/me');
      final List data = response.data['data'];
      if (kDebugMode) print('Response getCart: ${response.data}');
      return data.map((json) => CartItemModel.fromJson(json)).toList();
    } on DioError catch (e) {
      if (kDebugMode) print('Error getCart: ${e.response?.data}');
      throw Exception('Gagal mengambil data keranjang');
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      final response = await dio.post(
        '/cart',
        data: {
          'productId': productId,
          'quantity': quantity,
        },
      );
      if (kDebugMode) print('Berhasil tambah ke keranjang: ${response.data}');
    } on DioError catch (e) {
      if (kDebugMode) print('Error addToCart: ${e.response?.data}');
      final msg = e.response?.data?['message'] ?? 'Gagal menambah ke keranjang';
      throw Exception(msg);
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      await dio.patch(
        '/cart/$itemId',
        data: {'quantity': quantity},
      );
    } catch (e) {
      throw Exception('Gagal mengupdate jumlah');
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      await dio.delete(
        '/cart/$itemId',
      );
    } catch (e) {
      throw Exception('Gagal menghapus item dari keranjang');
    }
  }

  Future<void> clearCart() async {
    try {
      await dio.delete(
        '/cart',
      );
    } catch (e) {
      throw Exception('Gagal mengosongkan keranjang');
    }
  }
}
