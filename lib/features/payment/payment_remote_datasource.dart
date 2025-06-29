// lib/features/payment/payment_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend_ecommerce/features/payment/payment_success_model.dart';

class PaymentRemoteDatasource {
  final Dio dio;

  PaymentRemoteDatasource(this.dio);

  // Mengirim orderId ke backend untuk membuat transaksi pembayaran
  Future<PaymentSuccessModel> createPayment(String orderId) async {
    try {
      final response = await dio.post(
        '/payments/create', // <-- Endpoint yang sudah Anda siapkan di backend
        data: {
          'orderId': orderId, // Hanya kirim orderId
        },
      );

      if (kDebugMode) print('Response createPayment: ${response.data}');

      // Asumsi backend mengembalikan struktur yang bisa diparse PaymentSuccessModel
      // Pastikan 'data' key ada di respons backend Anda
      return PaymentSuccessModel.fromJson(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print(
            'Error createPayment: ${e.response?.statusCode} - ${e.response?.data}');
      }
      final msg = e.response?.data?['message'] ?? 'Gagal membuat pembayaran';
      throw Exception(msg);
    } catch (e) {
      if (kDebugMode) print('Unexpected error createPayment: $e');
      throw Exception(
          'Terjadi kesalahan tidak terduga saat membuat pembayaran.');
    }
  }
}
