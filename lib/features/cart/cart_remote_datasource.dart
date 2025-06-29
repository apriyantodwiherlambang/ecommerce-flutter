import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Untuk kDebugMode
import 'package:frontend_ecommerce/features/auth/data/api_service.dart'; // Tetap import jika ApiService masih digunakan

import './cart_model.dart'; // Pastikan path ini benar untuk model keranjang Anda

class CartRemoteDatasource {
  final Dio dio;
  final ApiService apiService; // Tetap di sini jika Anda ingin menggunakannya,
  // tapi perhatikan bahwa Dio sudah terintersep JWT.

  // Konstruktor menerima instance Dio dan ApiService yang sudah diinjeksi.
  // Hapus `dio.interceptors.clear()` dan penambahan interceptor di dalam konstruktor ini.
  // Interceptor global untuk JWT sudah ditambahkan di `injection_container.dart`.
  CartRemoteDatasource(this.dio, this.apiService);

  Future<List<CartItemModel>> getCart() async {
    try {
      // Menggunakan instance `dio` yang sudah diinjeksi dan sudah terintersep JWT.
      // Path `/cart/me` ini spesifik untuk mendapatkan keranjang user yang login.
      final response = await dio.get('/cart/me');
      final List data = response.data['data'];
      if (kDebugMode) print('Response getCart: ${response.data}');
      return data.map((json) => CartItemModel.fromJson(json)).toList();
    } on DioError catch (e) {
      if (kDebugMode) {
        print('Error getCart: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception(
          'Gagal mengambil data keranjang: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      if (kDebugMode) print('Unexpected error getCart: $e');
      throw Exception(
          'Terjadi kesalahan tidak terduga saat mengambil keranjang.');
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      // Menggunakan instance `dio` yang sudah diinjeksi dan sudah terintersep JWT.
      final response = await dio.post(
        '/cart',
        data: {
          'productId': productId,
          'quantity': quantity,
        },
      );
      if (kDebugMode) print('Berhasil tambah ke keranjang: ${response.data}');
      // Pastikan backend mengembalikan status 200 atau 201 untuk sukses.
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Gagal menambahkan ke keranjang: Status ${response.statusCode}');
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(
            'Error addToCart: ${e.response?.statusCode} - ${e.response?.data}');
      }
      final msg = e.response?.data?['message'] ?? 'Gagal menambah ke keranjang';
      throw Exception(msg);
    } catch (e) {
      if (kDebugMode) print('Unexpected error addToCart: $e');
      throw Exception(
          'Terjadi kesalahan tidak terduga saat menambah ke keranjang.');
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      final response = await dio.patch(
        '/cart/$itemId',
        data: {'quantity': quantity},
      );
      if (kDebugMode)
        print('Berhasil update jumlah keranjang: ${response.data}');
      if (response.statusCode != 200) {
        throw Exception(
            'Gagal mengupdate jumlah: Status ${response.statusCode}');
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(
            'Error updateQuantity: ${e.response?.statusCode} - ${e.response?.data}');
      }
      final msg = e.response?.data?['message'] ?? 'Gagal mengupdate jumlah';
      throw Exception(msg);
    } catch (e) {
      if (kDebugMode) print('Unexpected error updateQuantity: $e');
      throw Exception(
          'Terjadi kesalahan tidak terduga saat mengupdate jumlah.');
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      final response = await dio.delete(
        '/cart/$itemId',
      );
      if (kDebugMode)
        print('Berhasil menghapus item dari keranjang: ${response.data}');
      if (response.statusCode != 200) {
        throw Exception(
            'Gagal menghapus item dari keranjang: Status ${response.statusCode}');
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(
            'Error removeFromCart: ${e.response?.statusCode} - ${e.response?.data}');
      }
      final msg =
          e.response?.data?['message'] ?? 'Gagal menghapus item dari keranjang';
      throw Exception(msg);
    } catch (e) {
      if (kDebugMode) print('Unexpected error removeFromCart: $e');
      throw Exception('Terjadi kesalahan tidak terduga saat menghapus item.');
    }
  }

  Future<void> clearCart() async {
    try {
      final response = await dio.delete('/cart');
      if (kDebugMode)
        print('Berhasil mengosongkan keranjang: ${response.data}');
      if (response.statusCode != 200) {
        throw Exception(
            'Gagal mengosongkan keranjang: Status ${response.statusCode}');
      }
    } on DioError catch (e) {
      if (kDebugMode) {
        print(
            'Error clearCart: ${e.response?.statusCode} - ${e.response?.data}');
      }
      final msg =
          e.response?.data?['message'] ?? 'Gagal mengosongkan keranjang';
      throw Exception(msg);
    } catch (e) {
      if (kDebugMode) print('Unexpected error clearCart: $e');
      throw Exception(
          'Terjadi kesalahan tidak terduga saat mengosongkan keranjang.');
    }
  }
}
