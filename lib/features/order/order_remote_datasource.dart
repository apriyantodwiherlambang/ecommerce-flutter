// lib/features/order/order_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class OrderRemoteDatasource {
  final Dio dio;

  OrderRemoteDatasource(this.dio);

  // Endpoint untuk membuat order dari keranjang
  // Tambahkan parameter untuk data yang diperlukan
  Future<String> createOrderFromCart({
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    try {
      final response = await dio.post(
        '/orders/create-from-cart',
        data: {
          // Kirim data sebagai body JSON
          'shippingAddress': shippingAddress,
          'paymentMethod': paymentMethod,
        },
      );
      if (kDebugMode) print('Response createOrderFromCart: ${response.data}');
      // Asumsi backend mengembalikan orderId di 'data.orderId'
      final orderId =
          response.data['order']['id'] as String; // Sesuaikan path jika berbeda
      return orderId;
    } on DioException catch (e) {
      if (kDebugMode) {
        print(
            'Error createOrderFromCart: ${e.response?.statusCode} - ${e.response?.data}');
      }
      final msg =
          e.response?.data?['message'] ?? 'Gagal membuat order dari keranjang';
      throw Exception(msg);
    } catch (e) {
      if (kDebugMode) print('Unexpected error createOrderFromCart: $e');
      throw Exception('Terjadi kesalahan tidak terduga saat membuat order.');
    }
  }
}
